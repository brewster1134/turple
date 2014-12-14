require 'cli_miami'
require 'thor'

class Turple::Cli < Thor
  desc 'ate', 'Interpolate your template!'
  option :turplefile, type: :string, default: File.join(Dir.pwd, 'Turplefile'), aliases: ['-t'], desc: 'Path to a Turplefile with data (and optional template path).'
  option :template, type: :string, desc: 'Path to a template.'
  option :destination, type: :string, default: Dir.pwd, desc: 'Path to save interpolated template to.'
  def ate
    # update turpleobject object with Turplefile contents
    Turple.load_turplefile options['turplefile']

    # update turpleobject object with cli options
    Turple.turpleobject = {
      template: options['template'],
      configuration: {
        destination: options['destination'],
        cli: true
      }
    }

    # initialize turple
    Turple.ate Turple.template, Turple.data, Turple.configuration
  end
end
