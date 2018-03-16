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
