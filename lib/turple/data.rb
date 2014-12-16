class Turple::Data
  # attr_reader :data_map, :missing_data

private

  def initialize required_data, provided_data, data_map = {}
    @required_data = required_data
    @provided_data = provided_data
    @data_map = build_data_map @required_data, data_map
    @missing_data = missing_data @required_data, @provided_data, @data_map

    unless @missing_data.empty?
      prompt_for_data @missing_data
    end
  end

  # merge existing data map with generated values of concatenated parent keys
  # @param required_data [Hash] hash of required data
  # @param data_map [Hash] hash of existing data map
  # @return [Hash] complete data map hash
  #
  def build_data_map required_data, data_map
    build_parent_keys(required_data).deep_merge data_map
  end

  # create a new hash with the values replaced with an array of parent keys
  # @param hash [Hash] hash to process
  # @param keys [Array] initial array of keys (used internally for recursive functionlity)
  # @return [Hash] mirrored hash with array of parent keys instead of the intial value
  #
  def build_parent_keys hash, keys = []
    # go through each key-value pair
    hash.each do |key, val|
      # if the value is a Hash, recurse and add the key to the array of parents
      if val.is_a? Hash
        build_parent_keys(val, keys.push(key))
        # remove last parent when we're done with this pair
        keys.pop
      else
        # if the value is not a Hash, set the value to parents + current key
        hash[key] = keys + [key]
      end
    end
  end

  # remove provided data from required data, and create a new map with optional data map values
  # @param required_data [Hash] hash of all the data neccessary to interpolate a template
  # @param provided_data [Hash] hash of all the data collected from turplefile
  # @param data_map [Hash] hash of descriptions of required data
  # @return [Hash] hash of missing data with data map descriptions (or nested keys)
  #
  def missing_data required_data, provided_data, data_map
    required_data.keys.inject({}) do |diff, k|
      # if the hashes dont match on a particular key...
      if required_data[k] != provided_data[k]
        if required_data[k].is_a?(Hash) && provided_data[k].is_a?(Hash)
          diff[k] = missing_data(required_data[k], provided_data[k], data_map[k])
        else
          # set the key to false if it doesnt exist in the 2nd hash
          unless provided_data[k]
            # if data map value exists, use it
            diff[k] = data_map[k]
          end
        end
      end
      diff
    end
  end

  # loop through the missing data hash and prompt user to enter said data
  # @param missing_data [Hash] hash of missing data
  # @return [Hash] complete data hash
  #
  def prompt_for_data missing_data
    missing_data.each do |key, value|

    end
  end
end
