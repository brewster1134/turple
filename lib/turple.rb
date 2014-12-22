require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'yaml'

# Create CLI Miami presets
S.set_preset :error, {
  :color => :red,
  :style => :bold
}
S.set_preset :prompt, {
  :color => :blue,
  :style => :bright
}

class Turple
  # classes
  require 'turple/cli'
  require 'turple/data'
  require 'turple/interpolate'
  require 'turple/template'

  # Allows Turple.ate vs Turple.new
  class << self
    alias_method :ate, :new
  end

  @@turpleobject = {
    :template => '',
    :data => {},
    :data_map => {},
    :configuration => {
      # default regex for file names to interpolate content of
      # matches files with an extension of `.turple`
      # (e.g. foo.txt.turple)
      :file_ext => 'turple',

      # default regex for path interpolation
      # make sure to include the path_separator
      # matches capitalized, dot-notated keys surrounded with single brackets
      # (e.g. [FOO.BAR])
      :path_regex => '\[([A-Z_\.]+)\]',

      # default separator for attributes in the path
      # the separator must exist in the path_regex capture group
      # (e.g. [FOO.BAR])
      :path_separator => '.',

      # default regex for content interpolation
      # make sure to include the content_separator
      # matches lowercase, dot-notated keys surrounded with `<>`
      # (e.g. <>foo.bar<>)
      :content_regex => '<>([a-z_\.]+)<>',

      # default separator for attributes in file contents
      # the separator must exist in the content_regex capture group
      # (e.g. <>foo.bar<>)
      :content_separator => '.',

      # if not destination is provided, create in a generic turple subdir of the pwd dir
      :destination => 'turple'
    }
  }

  # Get loaded turplefiles contents
  # @return [Hash]
  #
  def self.turpleobject; @@turpleobject; end

  # allows helper accessors for turpleobject
  #
  def self.method_missing method
    self.turpleobject[method] || super
  end

  # Read yaml turplefile and add contents to the turpleobject
  #
  # @param file [String] relative/absolute path to a turplefile
  # @return [Hash]
  #
  def self.load_turplefile turplefile_path
    # return false if file doesnt exist
    turplefile_path = File.expand_path turplefile_path
    return false unless File.exists? turplefile_path

    self.turpleobject = YAML.load File.read turplefile_path
  end

  # Add additional data to the collective turplefile
  # @param hash [Hash] any hash of data to be merged into existing turplefile data
  # @return [Hash] merged turplefile data with symbolized keys
  def self.turpleobject= hash
    @@turpleobject.deep_merge! hash.deep_symbolize_keys
  end

  # check that the destination path doesnt exist... turple creates a new directory from a template
  # @return [Boolean]
  #
  def valid_destination?
    !@destination_path.nil? && !@destination_path.empty?
  end

  # prompt the user for a template path until a vaid one is entered
  # create the destination directory if it doesnt not exist
  # @return [String] valid template path
  #
  def prompt_for_destination_path
    until valid_destination?
      A.sk 'Enter a path to save your project to', :preset => :prompt, :readline => true do |response|
        @destination_path = File.expand_path response
      end
    end

    Turple.turpleobject = {
      :configuration => {
        :destination => File.expand_path(@destination_path)
      }
    }
  end

private

  def initialize template_path, data_hash, configuration_hash
    template_path = File.expand_path template_path
    data_hash = Turple.data.deep_merge data_hash
    data_map_hash = Turple.data_map
    configuration_hash = Turple.configuration.deep_merge configuration_hash

    # validate destination path
    @destination_path = configuration_hash[:destination]
    unless valid_destination?
      if configuration_hash[:cli]
        prompt_for_destination_path
      else
        raise S.ay 'Please use a non-existent directory.  Turple will create it.', :error
      end
    end

    # Initialize components
    template = Turple::Template.new template_path, configuration_hash
    data = Turple::Data.new template.required_data, data_hash, data_map_hash
    Turple::Interpolate.new template, data, @destination_path
  end
end
