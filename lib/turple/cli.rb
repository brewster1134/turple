# dependencies
require 'active_support/core_ext/object/deep_dup'
require 'active_support/inflector'
require 'i18n'
require 'cli_miami/global'
require 'thor'

# turple library
require 'turple'
# require 'turple/cli/data'
# require 'turple/cli/project'
# require 'turple/cli/source'
# require 'turple/cli/template'
require 'turple/version'

#
# Turple::Cli
# Collects user information and initializes Turple
# @see help Run `turple help` from the command line
#
class Turple::Cli < Thor
  desc 'ate', I18n.t('turple.cli.ate.desc')
  # @!visibility private
  def ate
    # Request information from user
    template = self.ask_user_for_source_or_template
    project = self.ask_user_for_project
    data = self.ask_user_for_data template, project

    # Start turple with valid data
    Turple::Core.new source: template.source, template: template, project: project, data: data
  end
  default_task :ate

  desc 'version', I18n.t('turple.cli.version.desc')
  # @!visibility private
  def version
    S.ay Turple::VERSION
  end

  # Intercept the default Thor help method to customize the description
  desc 'help [COMMAND]', I18n.t('turple.cli.help.desc')
  # @!visibility private
  def help command = nil;
    super
  end

  no_commands do
    # INIT VENDORED LIBRARIES
    #
    CliMiami.set_preset :turple_error, {
      color: :red,
      style: :bold
    }
    CliMiami.set_preset :turple_prompt, {
      color: :blue,
      style: :bright
    }
    CliMiami.set_preset :turple_key, {
      color: :blue,
      justify: :rjust,
      newline: false,
      padding: 40,
      preset: :prompt,
      style: :bright
    }
    CliMiami.set_preset :turple_value, {
      indent: 1
    }

    #
    # USER METHODS
    #
    # ASK METHODS
    #

    # Ask the user to choose a template, or enter new sources
    # @return Turple::Template
    #
    def ask_user_for_source_or_template
      template = nil
      source_i18n = I18n.t('turple.cli.ask_user_for_source_or_template.source')
      template_i18n = I18n.t('turple.cli.ask_user_for_source_or_template.template')

      until template.instance_of? Turple::Template
        self.show_user_templates

        # ask user what they want to do
        response = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_source_or_template.prompt'),
          type: :multiple_choice,
          max: 1,
          choices: {
            source: source_i18n,
            template: template_i18n
          }
        ).value.first

        # call method based on user's response
        case response
        when :source
          self.ask_user_for_source
        when :template
          template = self.ask_user_for_template
        end
      end

      return template
    end

    # Prompt user to enter a new source location
    # @return Turple::Source
    #
    def ask_user_for_source
      source = nil

      until source.instance_of? Turple::Source
        response = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_source.prompt')).value

        # allow user to exit without adding a new source
        break if response == ''

        # initialize a new source
        source = Turple::Source.new response
      end

      return source
    end

    # Prompt user to select an existing template
    # @return Turple::Template
    #
    def ask_user_for_template
      template = nil

      # collect all templates and build cli choices to show the user
      choices = {}
      Turple::Source.all.each do |source|
        CliMiami::S.ay source.name

        source.templates.each do |template|
          CliMiami::S.ay template.name

          key = "#{source.name}##{template.name}"
          value = template
          choices[key] = value
        end
      end

      # prompt user for template
      until template.instance_of? Turple::Template
        response = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_template.prompt'),
          type: :multiple_choice,
          max: 1,
          choices: choices
        ).value.first

        break if response == ''

        template = choices[response]
      end

      return template
    end

    # Prompt user for the new project location
    # @return Turple::Project
    #
    def ask_user_for_project
      project = nil

      until project.instance_of? Turple::Project
        response = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_project.prompt')).value

        # allow user to exit without adding a new project
        break if response == ''

        # initialize a new project
        project = Turple::Project.new response
      end

      return project
    end

    # Prompt user for the required data
    # @param Turple::Template
    # @param Turple::Project
    # @return Hash
    #
    def ask_user_for_data template, project
      required_data = template.required_data
      required_data_descriptions = template.required_data_descriptions
      existing_data = project.data

      ask_user_for_data_from_hash required_data, required_data_descriptions, existing_data
    end

    def ask_user_for_data_from_hash required_data, required_data_descriptions, existing_data, parent_keys = []
      # ensure an empty hash
      required_data_descriptions ||= {}
      existing_data ||= {}

      required_data.keys.inject({}) do |user_data, key|

        # if value already exists
        user_data[key] = if existing_data[key]
          existing_data[key]

        # call recursively for each nested hash
        elsif required_data[key].is_a? Hash
          # keep tracking of parent keys in case we need them if a description is missing
          parent_keys << key

          ask_user_for_data_from_hash required_data[key], required_data_descriptions[key], existing_data[key], parent_keys

        # prompt user for value
        else
          ask_user_for_data_from_description required_data_descriptions[key] || parent_keys.join(' ').titleize
        end

        # return user_data
        user_data
      end
    end

    def ask_user_for_data_from_description description

    end

    # SHOW METHODS
    #

    # Show user all templates from all sources
    #
    def show_user_templates
    end
  end
end
