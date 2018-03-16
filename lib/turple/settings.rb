#
# Turple::Settings
# Loads and organizes the data from multiple Turplefiles
#
# @dependency recursive-open-struct
#
class Turple::Settings
  def initialize
    # copy default settings as base
    @settings = RecursiveOpenStruct.new Turple::DEFAULT_SETTINGS

    # load settings from various Turplefiles
    load_turplefile :home, ENV['HOME']
    load_turplefile :pwd, __dir__
  end

  # Request a subset of the settings by use the key as a method name
  #
  def method_missing method, *args
    settings_key = @settings.send method
    settings_key ? settings_key : super
  end

  # Search for, load, and merge the Turplefile from a given directory
  #
  # @param type [Symbol] One of the supported Turplefile source types
  # @param directory [String] Path to a local directory that contains a Turplefile
  # @return turplefile [Hash, false] A ruby object of the imported yaml Turplefile, or false if none was found
  #
  def load_turplefile type, directory
    # @TODO populate settings hash based on type
    # @TODO copy sources to shared sources hash
  end

  def initialize_sources
  end
end
