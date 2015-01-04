require 'thor'

class Turple::Cli < Thor
  desc 'ate', 'Interpolate a template!'
  option :template, :type => :string, :aliases => ['-t'], :desc => 'Path to, or name of, a turple template.'
  option :destination, :type => :string, :aliases => ['-d'], :desc => 'Path to save interpolated template to.'
  def ate
    # update turpleobject object with cli options
    Turple.turpleobject = {
      template: options['template'] || Turple.template,
      destination: options['destination'] || Turple.destination,
      configuration: {
        cli: true
      }
    }

    # initialize turple
    Turple.ate Turple.template
  end

  default_task :ate
end
