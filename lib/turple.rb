# DEPENDENCIES
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/deep_dup'
# require 'fileutils'
require 'i18n'
# require 'pathname'
# require 'recursive-open-struct'
# require 'tmpdir'
require 'yaml'

# I18N
# load turple gem locales & set locale based on system settings
I18n.load_path += Dir['i18n/**/*.yml']
I18n.reload!
I18n.locale = ENV['LANG'].split('.').first.downcase

# Create Turple module & helper method
#
module Turple
  def self.ate configuration
    Turple::Core.new configuration
  end

  def self.version
    Turple::VERSION
  end
end

# TURPLE LIBRARY
require 'turple/core'
require 'turple/project'
require 'turple/source'
require 'turple/template'
require 'turple/version'
