# DEPENDENCIES
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/inflector'
require 'i18n'
require 'recursive-open-struct'
require 'sourcerer_'
require 'tmpdir'
require 'yaml'

# I18N
# load turple gem locales & set locale based on system settings
I18n.load_path += Dir[File.expand_path(File.join('i18n', '*.yml'))]
I18n.locale = ENV['LANG'].split('.').first.downcase
I18n.reload!

class Hash
  # deep diff between hashes
  def - b
    a = self
    (a.keys | b.keys).inject({}) do |diff, k|
      if a[k] != b[k]
        if a[k].respond_to?(:-) && b[k].respond_to?(:-)
          diff[k] = a[k] - b[k]
        else
          diff[k] = a[k] if a[k]
        end
      end
      diff.reject{ |k,v| v.empty? }
    end
  end

  # deep to_s with formatting
  def to_s namespace = []
    self.inject([]) do |array, (k, v)|
      tmp_namespace = namespace.dup << k
      
      # add to array
      array << if v.is_a? Hash
        
        # if a nested hash, call to_s with the parent key as a namespace
        v.to_s(tmp_namespace)
      else
        
        # stringify key and value
        key = tmp_namespace.join('.')
        "#{key}: #{v}"
      end

    end.join(', ')
  end
end

# Create Turple module & helper method
#
module Turple
  def self.ate args
    Turple::Source.new 'brewster1134/turple-templates'
    Turple::Core.load_turplefile ENV['HOME']
    Turple::Core.new args
  end
end

# TURPLE LIBRARY
require 'turple/core'
require 'turple/error'
require 'turple/project'
require 'turple/source'
require 'turple/template'
require 'turple/metadata'
