#
# Turple::Cli
# Defines command line options and handles collecting information from the user
# @see help Run `turple help` from the command line
#
# Dependencies
require 'i18n'
require 'cli_miami/global'
require 'thor'

class Turple::Cli < Thor
  desc 'ate', I18n.t('turple.cli.ate.desc')
  # @!visibility private
  def ate
    Turple::Source.new 'brewster1134/turple-templates'
    Turple::Core.load_turplefile ENV['HOME']

    # Request information from user
    template  = self.ask_user_for_source_or_template
    project   = self.ask_user_for_project template

    # Start turple with valid data
    Turple::Core.new template: template, project: project
  end
  default_task :ate

  desc 'version', I18n.t('turple.cli.version.desc')
  # @!visibility private
  def version
    S.ay Turple::VERSION
  end

  desc 'help [COMMAND]', I18n.t('turple.cli.help.desc')
  # @!visibility private
  def help command = nil
    super
  end

  no_commands do

    #
    # ASK METHODS
    #

    # Ask the user to choose a template, or enter new sources
    # @return [Turple::Template]  A Turple Template instance to build the project with
    #
    def ask_user_for_source_or_template
      source_i18n = I18n.t('turple.cli.ask_user_for_source_or_template.source')
      template_i18n = I18n.t('turple.cli.ask_user_for_source_or_template.template')

      template = nil
      until template.instance_of? Turple::Template
        Turple::Source.all.each do |source|
          CliMiami::S.ay source.name

          source.templates.each do |template|
            CliMiami::S.ay template.name
          end
        end

        # ask user what they want to do
        source_or_template = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_source_or_template.prompt'),
          type: :multiple_choice,
          max: 1,
          choices: {
            source: source_i18n,
            template: template_i18n
          }
        ).value.first

        # call method based on user's response
        case source_or_template
        when :source
          self.ask_user_for_source
        when :template
          template = self.ask_user_for_template
        end
      end

      return template
    end

    # Prompt user to enter a new source location
    # @return [Turple::Source]  A supported source location
    # @see  http://www.rubydoc.info/github/brewster1134/sourcerer/master
    #
    def ask_user_for_source
      source = nil
      until source.instance_of? Turple::Source
        source_location = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_source.prompt')).value

        # allow user to exit without adding a new source
        break if source_location == ''

        # initialize a new source
        source = Turple::Source.new source_location
      end

      return source
    end

    # Prompt user to select an existing template
    # @return [Turple::Template]  A Turple Template instance to build the project with
    #
    def ask_user_for_template
      # collect all templates and build cli choices to show the user
      templates = []
      Turple::Source.all.each do |source|
        CliMiami::S.ay source.name

        source.templates.each do |template|
          CliMiami::S.ay template.name

          templates << template
        end
      end

      # prompt user for template
      template = nil
      until template.instance_of? Turple::Template
        template_index = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_template.prompt'),
          type: :multiple_choice,
          max: 1,
          choices: templates
        ).value.first.to_i - 1

        template = templates[template_index]
      end

      return template
    end

    # Prompt user for the new project location
    # @param  template  [Turple::Template]  The Turple Template to collect data for
    # @return [Turple::Project] A complete Turple Project ready to be created
    #
    def ask_user_for_project template
      project_path = nil
      until project_path.is_a?(Pathname) && !project_path.to_s.empty?
        project_path = Pathname.new CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_project.path_prompt')).value
      end

      # load Turplefile if it exists
      Turple::Core.load_turplefile project_path if project_path.exist?

      # ask user for project name if not set
      project_name = Turple::Core.settings[:project][:name]
      until !project_name.nil? && !project_name.empty?
        project_name = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_project.name_prompt')).value
      end

      # ask user for remaining data
      project_data = ask_user_for_data template.required_data, Turple::Core.settings[:project][:data]

      # initialize a new project
      return Turple::Project.new name: project_name, path: project_path, data: project_data, template: template
    end

    # Prompt user for missing data
    # @param  required_data [Hash]  All required data for template
    # @param  existing_data [Hash]  Any data already set on the project
    # @param  [Hash]  The entered users data mirroring the required data object
    #
    def ask_user_for_data required_data, existing_data
      existing_data ||= {}
      new_data = {}

      required_data.keys.inject(new_data) do |user_data, key|
        # if value already exists
        user_data[key] = if existing_data[key]
          existing_data[key]

        # call recursively for each nested hash
        elsif required_data[key].is_a? Hash
          ask_user_for_data required_data[key], existing_data[key]

        # prompt user for value
        else
          ask_user_for_data_value required_data[key]
        end

        # return user_data
        user_data
      end

      return new_data
    end

    # Prompt user for a single value
    # @param  description [String]  Text to prompt the user with what to enter
    # @return [String]  The user provided value
    #
    def ask_user_for_data_value description
      value = nil
      until !value.nil? && !value.empty?
        value = CliMiami::A.sk(description).value
      end

      return value
    end
  end
end
