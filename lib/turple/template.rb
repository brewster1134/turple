require 'active_support/core_ext/hash/deep_merge'
require 'cli_miami'
require 'find'

class Turple::Template
  attr_accessor :path, :required_data, :configuration, :name

private

  def initialize path, configuration
    @path = path
    @configuration = configuration

    # validate template path
    unless valid_path?
      if @configuration[:cli]
        prompt_for_path
      else
        raise S.ay "Invalid Path `#{@path}`", :error
      end
    end

    # load template turplefile after validating path
    Turple.load_turplefile File.join(@path, 'Turplefile')

    # validate configuration after loading turplefile
    valid_configuration?

    # set data variables after validating path and configuration
    @required_data = scan_for_data @path
    @name = Turple.turpleobject[:name] || File.basename(@path)
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
        path_regex = Regexp.new @configuration[:path_regex]
        if path =~ path_regex
          capture_groups = path.scan(path_regex).flatten

          capture_groups.each do |group|
            group_attributes = group.split(@configuration[:path_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            required_data.deep_merge! group_attributes_hash
          end
        end

        # process file contents
        content_regex = Regexp.new @configuration[:content_regex]
        if path =~ /\.#{Regexp.escape(@configuration[:file_ext])}$/
          capture_groups = File.read(path).scan(content_regex).flatten

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
      raise S.ay 'No Required Data - Nothing found to interpolate.  Make sure your configuration matches your template.', :error
    end

    return required_data
  end

  # check that the path is a valid template
  # @return [Boolean]
  #
  def valid_path?
    File.exists?(@path) && File.exists?(File.join(@path, 'Turplefile'))
  end

  # prompt the user for a template path until a vaid one is entered
  # @return [String] valid template path
  #
  def prompt_for_path
    until valid_path?
      A.sk 'Enter a path to a Turple Template', :preset => :prompt, :readline => true do |response|
        @path = File.expand_path response
      end
    end
    @path
  end

  # check the configuration is valid
  # @return [Boolean]
  #
  def valid_configuration?
    # check that a configuration exists
    if @configuration.empty?
      raise S.ay 'No Configuration Found', :error
    end

    # check that a configuration values are valid
    #
    # make sure the string is a valid extension with no period's in it
    if !@configuration[:file_ext].is_a?(String) ||
        @configuration[:file_ext] =~ /\./
      raise S.ay "`file_ext` is invalid.  See README for requirements.", :error
    end

    if !@configuration[:path_separator].is_a?(String)
      raise S.ay "`path_separator` is invalid.  See README for requirements.", :error
    end

    if !@configuration[:content_separator].is_a?(String)
      raise S.ay "`content_separator` is invalid.  See README for requirements.", :error
    end

    # make sure it contains the path separator in the capture group
    if !(@configuration[:path_regex] =~ /\(.*#{Regexp.escape(@configuration[:path_separator])}.*\)/)
      raise S.ay "`path_regex` invalid.  See README for requirements.", :error
    end

    # make sure it contains the path separator in the capture group
    if !(@configuration[:content_regex] =~ /\(.*#{Regexp.escape(@configuration[:content_separator])}.*\)/)
      raise S.ay "`content_regex` invalid.  See README for requirements.", :error
    end

    return true
  end
end
