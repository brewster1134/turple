require 'thor'

class Turple::Cli < Thor
  desc 'ate', 'Interpolate a template!'
  option :template, :type => :string, :aliases => ['-t'], :desc => 'Path to, or name of, a turple template.'
  option :destination, :type => :string, :aliases => ['-d'], :desc => 'Path to save interpolated template to.'
  def ate
    # enable interactive mode
    Turple.turpleobject = { :interactive => true }

    # dont pass a nil destination
    configuration_hash = options['destination'] ? { :destination => options['destination'] } : {}

    # initialize turple
    Turple.ate options['template'], {}, configuration_hash
  end

  default_task :ate
end
