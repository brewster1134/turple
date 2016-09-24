# dependencies
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
    data = self.ask_user_for_data

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

      until template.instance_of? Turple::Template
        self.show_user_templates

        response = CliMiami::A.sk(I18n.t('turple.cli.ask_user_for_template.prompt')).value

        break if response == ''

        source_template_names = response.split('#')
        source_name = source_template_names[0]
        template_name = source_template_names[1]

        source = Turple::Source.get_source_by_name source_name

        template = source.get_template_by_name template_name
      end

      return template
    end

    # Prompt user for the new project location
    # @return Turple::Project
    #
    def ask_user_for_project
    end

    # Prompt user for the required data
    #
    def ask_user_for_data
    end

    # SHOW METHODS
    #

    # Show user all templates from all sources
    #
    def show_user_templates
    end
  end
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #   # Ask user to enter a new source, or choose an existing template
  #   # @return [String] 'source' or 'template'
  #   #
  #   def request_new_source_or_existing_template
  #     CliMiami::A.sk I18n.t('turple.cli.ate.source_or_template'), type: :multiple_choice, max: 1, choices: ['source', 'template']
  #   end
  #
  #   # Prompt user for a source location until a valid one is entered
  #   # @return [Turple::Source]
  #   #
  #   def request_new_source
  #     source = nil
  #
  #     until source
  #       CliMiami::A.sk I18n.t('turple.cli.source.request_new') do |response|
  #         begin
  #           source = Turple::Source.new :user, response
  #         rescue TurpleError => error
  #           CliMiami::S.ay error.message, :turple_error
  #         end
  #       end
  #     end
  #
  #     return source
  #   end
  #
  #   # Show user all templates grouped by source
  #   #
  #   def show_templates
  #     Turple::Source.sources
  #   end
  #
  #   # Prompt user for an existing template
  #   # @return [Turple::Template]
  #   #
  #   def select_template
  #     source_array = source_array || sources
  #
  #     # Display sources and templates
  #     show sources: source_array, templates: true
  #
  #     # build hash to match template choices with template
  #     template_hash = Hash.new
  #     source_array.each do |source|
  #       source.templates.each do |template|
  #         template_hash["#{source.name}: #{template.name}"] = template
  #       end
  #     end
  #
  #     CliMiami::A.sk I18n.t('turple.cli.source.select_template'), type: :multiple_choice, choices: template_hash.keys do |response|
  #       template = template_hash[response]
  #     end
  #
  #     return template
  #   end
  # end
end
