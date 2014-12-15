require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'find'

class Turple::Template
  attr_accessor :path, :required_data

private

  def initialize path, data, configuration
    # set basic variables
    @path = File.expand_path path
    @configuration = configuration

    # validate template path
    prompt_for_template unless valid_path?

    # load template turplefile after validatin path
    Turple.load_turplefile File.join(@path, 'Turplefile')

    # validate configuration
    valid_configuration?

    # set data variables after validating path and configuration
    @data = data.deep_symbolize_keys
    @required_data = scan_for_data @path
  end

  # Scan a path and determine the required data needed to interpolate it
  # @param template_path [String] path to a template file
  # @return [Hash] a hash of all the data needed
  #
  def scan_for_data template_path
    required_data = {}

    Find.find template_path do |path|
      if File.file?(path)

        # process file paths
        if path =~ @configuration[:path_regex]
          capture_groups = path.scan(@configuration[:path_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(@configuration[:path_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            required_data.deep_merge! group_attributes_hash
          end
        end

        # process file contents
        if path =~ /\.#{Regexp.escape(@configuration[:file_ext])}$/
          capture_groups = File.read(path).scan(@configuration[:content_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(@configuration[:content_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            required_data.deep_merge! group_attributes_hash
          end
        end
      end
    end

    # check that the template requires data
    if required_data.empty?
      raise S.ay 'Turple::Template - No Required Data - Nothing found to interpolate.  Make sure your configuration matches your template.', :error
    end

    return required_data
  end

  def prompt_for_template
    until valid_path?
      A.sk 'what template?', :readline => true do |response|
        @path = response
      end
    end
  end

  # check that the template path exists
  def valid_path?
    return true if File.exists? @path

    # in cli mode, return false so we can prompt the user for a template path
    # otherwise raise an exception
    if @configuration[:cli]
      return false
    else
      raise S.ay "Turple::Template - Invalid Path - #{@path}", :error
    end
  end

  def valid_configuration?
    # check that a configuration exists
    if @configuration.empty?
      raise S.ay 'Turple::Template - No Configuration Found', :error
    end

    # check that a configuration values are valid
    #
    if  !@configuration[:file_ext].is_a? String ||
        # make sure the string is a valid extension with no period's in it
        @configuration[:file_ext] =~ /^[^.]+$/
      raise S.ay "Turple::Template - `file_ext` is invalid.  See README for requirements.", :error
    end

    if !@configuration[:path_separator].is_a? String
      raise S.ay "Turple::Template - `path_separator` is invalid.  See README for requirements.", :error
    end

    if !@configuration[:content_separator].is_a? String
      raise S.ay "Turple::Template - `content_separator` is invalid.  See README for requirements.", :error
    end

    if  !@configuration[:path_regex].is_a? Regexp ||
        # make sure it contains the path separator in the capture group
        !@configuration[:path_regex].inspect =~ /\(.*#{Regexp.escape(@configuration[:path_separator])}.*\)/
      raise S.ay "Turple::Template - `path_regex` invalid.  See README for requirements.", :error
    end

    if  !@configuration[:content_regex].is_a? Regexp ||
        # make sure it contains the path separator in the capture group
        !@configuration[:content_regex].inspect =~ /\(.*#{Regexp.escape(@configuration[:content_separator])}.*\)/
      raise S.ay "Turple::Template - `content_regex` invalid.  See README for requirements.", :error
    end

    return true
  end
end
