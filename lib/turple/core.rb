#
# Turple::Core
# Acts as the controller and state of Turple session
#
class Turple::Core
  # Global settings hash
  @@settings = {}

  # Main entry point into Turple
  # @param [Hash] args
  # @option args [String]                   :source   ID, Name, or Path of a Turple Source
  # @option args [Turple::Template, String] :template Turple::Template instance -OR- ID, Name, or Path of a Turple Template
  # @option args [Turple::Project, Hash]    :project  Turple::Project instance -OR- Hash with Turple Project meta data
  # @return [Turple::Project]
  #
  def initialize args
    # search for the source, or initialize one if it doesn't already exist
    source = nil
    if args[:source]
      source = Turple::Source.find(args[:source]) || Turple::Source.new(args[:source])
    end

    # if the template is already a Turple::Template, it was created from the command line
    template = nil
    if args[:template].is_a? Turple::Template
      template = args[:template]

    # if the template is a string, search for it or create a new one
    elsif args[:template].is_a? String

      # if explicit source was passed
      if source.is_a? Turple::Source
        template = source.find_template args[:template]

        # if no template is found in specified source, raise an error
        unless template.is_a? Turple::Template
          raise Turple::Error.new I18n.t('turple.source.find_template.not_found', source_name: source.name, template_name: args[:template])
        end

      # search for the template, or initialize a new one if it doesn't already exist
      else
        template = Turple::Template.find(args[:template]) || Turple::Template.new(args[:template])
      end
    end

    # if the project is already a Turple::Project, it was created from the command line
    project = nil
    if args[:project].is_a? Turple::Project
      project = args[:project]

    # if the project is a string, treat string as path to project
    elsif args[:project].is_a? String
      Turple::Core.load_turplefile args[:project]
      project_settings = Turple::Core.settings[:project]
      project = Turple::Project.new name: project_settings[:name], path: File.expand_path(args[:project]), data: project_settings[:data], template: template

    # if the project is a hash, create a new one
    elsif args[:project].is_a? Hash
      project = Turple::Project.new name: args[:project][:name], path: args[:project][:path], data: args[:project][:data], template: template
    end

    return project
  end

  # Load a Turplefile from the provided path
  # @param local_dir [String] Local file system directory path
  # @param file_name [String] Name of the YAML file
  # @return [Hash]  Global settings or false if nothing found
  #
  def self.load_turplefile local_dir, file_name = 'Turplefile'
    absolute_path = File.expand_path File.join(local_dir, file_name)
    turplefile = YAML.load(File.read(absolute_path)).deep_symbolize_keys

    sources = turplefile[:sources] || []
    sources.each do |location|
      Turple::Source.new location
    end

    self.settings = turplefile
  end

  # Recursively merge settings into the Turple global settings hash
  # @param settings [Hash] Hash to apply to the global settings
  # @return [Hash] Global settings
  #
  def self.settings= settings
    @@settings.deep_merge! settings.deep_symbolize_keys
  end

  # Turple global settings hash
  # @return [Hash] Global settings
  #
  def self.settings
    @@settings
  end
end

# #
# # Turple::Core
# # Acts as the controller for the other Turple classes
# #
# class Turple::Core
#   attr_reader :settings
#
#   # STARTS TURPLE!
#   # @param configuration [Hash] Hash of data used to locate and interpolate a template
#   # @option opts [Turple::Settings] :settings An optional Turple::Settings object
#   # @option opts [String] :template The name of a template
#   # @option opts [String] :source The name or location of a source with the desired template
#   # @option opts [String] :project The path to save the interpolated template to
#   #
#   def initialize configuration
#     # Initialize Settings
#     @settings = configuration[:settings] || Turple::Settings.new
#
#     # Load Source(s) and get Template
#     source_name_or_location = configuration[:source]
#     template_name = find_template source_name_or_location, configuration[:template]
#     template = Turple::Template.new template_name
#
#     # Initialize Project
#     @project = Turple::Project.new configuration[:project], template
#   end
#
#   def self.project; end
#   def self.template; end
#
# private
#
#   # Load sources until the template is found
#   # @param source_name_or_location [String] Name of a source, or a valid source location
#   # @param template_name [String] Name of a valid template found within one of the available sources
#   # @return [Turple::Template] Turple::Template object
#   #
#   def find_template source_name_or_location, template_name
#     # Set the source & template variables
#     # Initialize optional user source
#     if source_name_or_location
#       # If user passed a source NAME, check if it has already been initialized
#       existing_source = Turple::Source.find_source_by_name source_name_or_location
#
#       # Use existing source if found
#       source = if existing_source
#         existing_source
#
#       # If user passed a source LOCATION, attempt to initialize it
#       else
#         Turple::Source.new :user, configuration[:source]
#       end
#
#       # Check if source has the desired template
#       template = source.find_template_by_name template_name
#
#     # Initialize loaded sources until the template is found
#     else
#       Turple::Settings.sources.each do |source_name, source_location|
#         # Initialize source
#         source = Turple::Source.new source_name, source_location
#
#         # Check if source has the desired template
#         template = source.find_template_by_name template_name
#
#         # If template is found, stop loading sources
#         template ? break : next
#       end
#     end
#
#     # Raise an error if the user's source does not contain the user's template
#     raise TurpleError(:source, :missing_template, template_name: template_name) unless template
#
#     return template
#   end
#
#
#
#
#   # collects all turple settings and merges them together
#   # * User settings (either from when running `turple` from the command line, or calling `Turple.ate` from a ruby app)
#   # * `Turplefile` from the home directory
#   # * `Turplefile` from the current directory
#   # * `Turplefile` from the current directory
#   #
#   # * `Turplefile` from the template
#   #
#   def get_settings init_settings
#     # copy default settings
#     # DEFAULT_SETTINGS = Turple::DEFAULT_SETTINGS.dup
#
#     # merge all settings together (ordered from least to highest precedence)
#     DEFAULT_SETTINGS
#       .deep_merge(load_turplefile(ENV['HOME']))
#       .deep_merge(load_turplefile(__dir__))
#       .deep_merge(init_settings)
#   end
#
#   # loads Turplefile from given directory
#   #
#   def load_turplefile directory
#   end
#
#   #
#   # OLD STUFF!!
#   #
#
#   # allows helper accessors for settings
#   #
#   def self.method_missing method
#     value = self.settings[method]
#     defined?(value) ? value : super
#   end
#
#   # Read yaml turplefile and add contents to the settings
#   #
#   # @param file [String] relative/absolute path to a turplefile
#   # @return [Hash]
#   #
#   def self.load_turplefile turplefile_path, update_settings = true
#     turplefile_path = File.expand_path turplefile_path
#
#     # return false if file doesn't exist
#     return false unless File.exists? turplefile_path
#
#     # read turplefile to ruby object
#     turplefile_data = YAML.load File.read turplefile_path
#
#     # update the settings, or return a symbolized hash
#     if update_settings
#       self.settings = turplefile_data
#     else
#       turplefile_data.deep_symbolize_keys
#     end
#   end
#
#   # Add additional data to the collective turplefile
#   #
#   # @param hash [Hash] any hash of data to be merged into existing turplefile data
#   # @return [Hash] merged turplefile data with symbolized keys
#   #
#   def self.settings= hash
#     @@settings.deep_merge! hash.deep_symbolize_keys
#   end
#
# private
#
#   def initialize_old template, destination, settings = {}
#     return
#
#     # load home turplefile
#     Turple.load_turplefile File.join(File.expand_path('~'), 'Turplefile')
#
#     # check if template path is an interpolated project
#     template_turplefile = Turple.load_turplefile(File.join(template_path, 'Turplefile'), false)
#     if template_turplefile && template_turplefile[:created_on]
#       # use the project template
#       template_path = template_turplefile[:template]
#
#       # load the project sources
#       Turple.settings = {
#         :sources => template_turplefile[:sources]
#       }
#     end
#
#     # create sources
#     Turple.sources.each do |source_name, source_path|
#       Turple::Source.new source_name, source_path
#     end
#
#     # update settings with initialized arguments
#     Turple.settings = {
#       :template => template_path,
#       :data => data_hash,
#       :configuration => configuration_hash
#     }
#
#     # initialize template after sources are created
#     @template = Turple::Template.new template_path, Turple.interactive
#
#     # set destination and load Turplefile
#     @destination_path = File.expand_path Turple.configuration[:destination]
#     Turple.load_turplefile File.join(@destination_path, 'Turplefile')
#
#     # collect data
#     data_hash = Turple.data.deep_merge data_hash
#     data_map_hash = Turple.data_map
#     configuration_hash = Turple.configuration.deep_merge configuration_hash
#
#     if Turple.interactive
#       S.ay 'Saving to: ', :preset => :prompt, :newline => false
#       S.ay @destination_path
#     end
#
#     # Initialize components
#     @data = Turple::Data.new @template.required_data, data_hash, data_map_hash
#     @interpolate = Turple::Interpolate.new @template, @data, @destination_path
#
#     output_summary if Turple.interactive
#   end
#
#   def output_summary
#     S.ay '=' * (@@settings[:cli_line_length] / 2), :turple_key
#     S.ay '=' * ((@@settings[:cli_line_length] / 2) - 1), :turple_value
#     S.ay '!TURPLE ', :turple_key
#     S.ay 'SUCCESS!', :turple_value
#     S.ay '=' * (@@settings[:cli_line_length] / 2), :turple_key
#     S.ay '=' * ((@@settings[:cli_line_length] / 2) - 1), :turple_value
#
#     S.ay 'Template', :turple_key
#     S.ay @template.name, :turple_value
#     S.ay 'Project', :turple_key
#     S.ay @interpolate.project_name, :turple_value
#
#     S.ay 'Turpleated Paths:', :turple_key
#     S.ay Dir[File.join(@destination_path, '**/*')].count.to_s, :turple_value
#     S.ay 'Turpleated In:', :turple_key
#     S.ay (@interpolate.time * 1000).round(1).to_s + 'ms', :turple_value
#
#     S.ay '=' * (@@settings[:cli_line_length] / 2), :turple_key
#     S.ay '=' * ((@@settings[:cli_line_length] / 2) - 1), :turple_value
#   end
# end
