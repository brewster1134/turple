require 'cli_miami'
require 'recursive-open-struct'

class Turple::Data
  def data; RecursiveOpenStruct.new @provided_data; end

private

  def initialize required_data, provided_data, data_map
    @provided_data = provided_data

    data_map = build_data_map required_data, Turple.data_map.deep_merge(data_map)
    missing_data = get_missing_data required_data, @provided_data, data_map

    # if there is missing data, prompt user to enter it in
    unless missing_data.empty?
      S.ay 'There is some missing data. You will be prompted to enter each value.', :color => :white, :bgcolor => :blue
      prompt_for_data missing_data
    end

    # update turpleobject with complete data
    Turple.turpleobject = { :data => @provided_data }
  end

  # populate missing data map values to match required data
  # uses a collection of the parent keys as the value
  #
  # @param required_data [Hash] hash of required data
  # @param data_map [Hash] hash of existing data map
  #
  # @return [Hash] complete data map hash
  #
  def build_data_map required_data, data_map
    build_data_map_keys(required_data).deep_merge data_map
  end

  # create a new hash with the values replaced with an array of parent keys
  #
  # @param hash [Hash] hash to process
  # @param keys [Array] initial array of keys (used internally for recursive functionlity)
  #
  # @return [Hash] mirrored hash with array of parent keys instead of the intial value
  #
  def build_data_map_keys hash, keys = []
    # go through each key-value pair
    hash.each do |key, val|
      # if the value is a Hash, recurse and add the key to the array of parents
      if val.is_a? Hash
        build_data_map_keys(val, keys.push(key))
        # remove last parent when we're done with this pair
        keys.pop
      else
        # if the value is not a Hash, set the value to parents + current key
        hash[key] = keys + [key]
      end
    end
  end

  # remove provided data from required data
  # create a new hash with data map values
  #
  # @param required_data [Hash] hash of all the data neccessary to interpolate a template
  # @param provided_data [Hash] hash of all the data collected from turplefile
  # @param data_map [Hash] hash of descriptions of required data
  #
  # @return [Hash] hash of missing data with data map descriptions (or nested keys)
  #
  def get_missing_data required_data, provided_data, data_map
    required_data.keys.inject({}) do |diff, k|
      # if the hashes dont match on a particular key...
      if required_data[k] != provided_data[k]
        if required_data[k].is_a?(Hash) && provided_data[k].is_a?(Hash)
          diff[k] = get_missing_data(required_data[k], provided_data[k], data_map[k])
        else
          # set the key to false if it doesnt exist in the 2nd hash
          unless provided_data[k]
            # if data map value exists, use it
            diff[k] = data_map[k]
          end
        end
      end
      diff.delete k if diff[k].nil? || diff[k].empty?
      diff
    end
  end

  # merges user-input missing data into the provided data
  #
  # @param missing_data [Hash] hash of missing data
  #
  # @return [Hash] complete provided data hash
  #
  def prompt_for_data missing_data
    @provided_data.deep_merge! prompt_for_data_keys(missing_data)
  end

  # loop through the missing data hash and prompt user to enter said data
  #
  # @param missing_data [Hash] hash of missing data
  #
  # @return [Hash] complete missing data hash
  #
  def prompt_for_data_keys missing_data
    missing_data.each do |key, value|
      if value.is_a? Hash
        missing_data[key] = prompt_for_data_keys value
      else
        value = value.join(' | ') if value.is_a? Array
        A.sk value, :prompt do |response|
          missing_data[key] = response
        end
      end
    end
    missing_data
  end
end
