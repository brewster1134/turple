require 'cli_miami'
require 'thor'

class Turple::Cli < Thor
  desc 'ate', 'Interpolate your template!'
  option :template, :type => :string, :desc => 'Path to a turple template.'
  option :destination, :type => :string, :default => File.join(Dir.pwd, 'turple'), :desc => 'Path to save interpolated template to.'
  def ate
    destination = File.expand_path options['destination']

    # load destination turplefile if it exists
    Turple.load_turplefile File.join(destination, 'Turplefile')

    # update turpleobject object with cli options
    Turple.turpleobject = {
      template: (options['template'] || Turple.template rescue nil),
      configuration: {
        destination: destination,
        cli: true
      }
    }

    # initialize turple
    Turple.ate Turple.template, Turple.data, Turple.configuration
  end

  default_task :ate
end
