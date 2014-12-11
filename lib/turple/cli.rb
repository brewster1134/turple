require 'cli_miami'
require 'thor'

class Turple::Cli < Thor
  desc 'ate', 'Process a template with some data'
  option :turplefile, type: :string, default: File.join(Dir.pwd, 'Turplefile'), aliases: ['-t'], desc: 'Path to a Turplefile with data. (Optionally set `template` vs passing --template.)'
  option :template, type: :string, desc: 'Path to a template. (If not defined, looks for `template` in Turplefile.)'
  option :destination, type: :string, default: Dir.pwd, desc: 'Path to save interpolated template to.'
  def ate
    # load a local turplefile for data and optional template path
    Turple.load_turplefile options['turplefile']

    # add configuration
    Turple.configuration[:cli] = true
    Turple.configuration[:destination] = options['destination']

    template = options['template'] || Turple.template || prompt_for_template
    data = Turple.data || prompt_for_data
    configuration = Turple.configuration

    # initialize turple
    Turple.ate template, data, configuration
  end

private

  def prompt_for_template
    template = nil

    until template
      A.sk 'what template?', :readline => true do |response|
        template = response if File.exists? File.expand_path response
      end
    end

    template
  end

  def prompt_for_data
  end
end
