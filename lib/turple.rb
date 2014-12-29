require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'
require 'cli_miami'
require 'yaml'

class Turple
  # classes
  require 'turple/cli'
  require 'turple/data'
  require 'turple/interpolate'
  require 'turple/template'

  # Create CLI Miami presets
  @@line_size = 80
  CliMiami.set_preset :error, {
    :color => :red,
    :style => :bold
  }
  CliMiami.set_preset :prompt, {
    :color => :blue,
    :style => :bright
  }
  CliMiami.set_preset :header, CliMiami.presets[:prompt].merge({
    :justify => :center,
    :padding => @@line_size
  })
  CliMiami.set_preset :key, CliMiami.presets[:prompt].merge({
    :justify => :rjust,
    :padding => @@line_size / 2,
    :preset => :prompt,
    :newline => false
  })
  CliMiami.set_preset :value, {
    :indent => 1
  }

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
    @@turpleobject.deep_merge! hash.deep_symbolize_keys
  end

private

  def initialize template_path, data_hash, configuration_hash
    data_hash = Turple.data.deep_merge data_hash
    data_map_hash = Turple.data_map
    configuration_hash = Turple.configuration.deep_merge configuration_hash
    @destination_path = configuration_hash[:destination]

    if configuration_hash[:cli]
      S.ay 'Saving to: ', :preset => :prompt, :newline => false
      S.ay @destination_path
    end

    # Initialize components
    @template = Turple::Template.new template_path, configuration_hash
    @data = Turple::Data.new @template.required_data, data_hash, data_map_hash
    @interpolate = Turple::Interpolate.new @template, @data, @destination_path

    output_summary if configuration_hash[:cli]
  end

  def output_summary
    S.ay '=' * @@line_size, :prompt
    S.ay '!TURPLE SUCCESS!', :preset => :header
    S.ay '=' * @@line_size, :prompt

    S.ay 'Turpleated ', :newline => false, :indent => 2
    S.ay @template.name, :newline => false, :preset => :prompt
    S.ay ' to a new project ', :newline => false
    S.ay @interpolate.project_name, :preset => :prompt

    S.ay 'Paths Turpleated:', :key
    S.ay Dir[File.join(@destination_path, '**/*')].count.to_s, :value
    S.ay 'Turpleated in:', :key
    S.ay (@interpolate.time * 1000).round(1).to_s + 'ms', :value
    S.ay '=' * @@line_size, :prompt
  end
end
