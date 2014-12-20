require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'yaml'

# Create CLI Miami presets
S.set_preset :error, {
  :color => :red,
  :style => :bold
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
      :content_separator => '.'
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
    @@turpleobject.merge! hash.deep_symbolize_keys
  end

private

  def initialize template, data, configuration = {}
  end
end
