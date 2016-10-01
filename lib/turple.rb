# dependencies
# require 'active_support/core_ext/hash/deep_merge'
# require 'active_support/core_ext/hash/keys'
# require 'active_support/core_ext/object/deep_dup'
# require 'fileutils'
require 'i18n'
# require 'pathname'
# require 'recursive-open-struct'
# require 'tmpdir'
# require 'yaml'

# I18N
# load turple gem locales & set locale based on system settings
I18n.load_path += Dir['i18n/**/*.yml']
I18n.reload!
I18n.locale = ENV['LANG'].split('.').first.downcase

# define turple global settings
#
module Turple
  require 'turple/core'
  # require 'turple/error'
  # require 'turple/data'
  # require 'turple/interpolate'
  require 'turple/project'
  # require 'turple/settings'
  require 'turple/source'
  require 'turple/template'
  # require 'turple/version'

  DEFAULT_SETTINGS = {
    # sources to look for turple templates
    # sources can be chosen by using the key name instead of the value
    # must use formats supported by the `sourcerer_` gem
    # https://github.com/brewster1134/sourcerer
    sources: {
      default: 'brewster1134/turple-templates'
    },

    # template meta data
    template: {
      name: nil,
      source: {
        default: 'brewster1134/turple-templates'
      },

      # data that is used to interpolate the template
      # in interactive mode:
      #   * can be pre-loaded from yaml
      #   * can be entered by the user with the turple wizard
      # in integrated mode:
      #   * can be pre-loaded from yaml
      #   * can be passed in an object during instantiation
      data: {},

      # maps data keys with descriptions for interactive mode
      data_descriptions: {},

      # interpolation settings required by the template
      # all examples use the example data:
      # { author: { first_name: 'John' }}
      settings: {
        # PATH INTERPOLATION OPTIONS
        #
        # EXAMPLE:
        #   * FROM: file_[AUTHOR.FIRST_NAME].txt
        #   *   TO: file_John.txt
        #
        # regex for file/folder path interpolation
        # !! MUST INCLUDE THE ESCAPED path_separator IN THE CHARACTER SET !!
        # DEFAULT:
        #   * only capital letters: A-Z
        #   * multi-word keys seperated with an underscore: _
        #   * surrounded by square brackets: [ ]
        path_regex: '\[([A-Z_\.]+)\]',

        # separator for nested attributes
        # DEFAULT: .
        path_separator: '.',

        # CONTENT INTERPOLATION OPTIONS
        #
        # EXAMPLE:
        #   * FROM: profile.txt.turple
        #   *   TO: profile.txt
        #
        # EXAMPLE:
        #   * FROM: The authors name is {{AUTHOR.FIRST_NAME}}
        #   *   TO: The authors name is John
        #
        # extension for files that need their content interpolated
        # DEFAULT: turple
        content_file_ext: 'turple',

        # regex for content interpolation
        # !! MUST INCLUDE THE ESCAPED content_separator IN THE CHARACTER SET !!
        # DEFAULT:
        #   * only capital letters: A-Z
        #   * multi-word keys seperated with an underscore: _
        #   * surrounded by double curly braces: {{ }}
        content_regex: '\{\{([A-Z_\.]+)\}\}',

        # separator for nested attributes
        # DEFAULT: .
        content_separator: '.'
      }
    },

    # basic project meta data
    project: {
      created_on: nil,

      # basic author meta data
      author: {
        name: nil,
        email: nil
      },

      # path to where the interpolated template should be saved
      path: File.join(Dir.pwd, 'turple'),

      url: nil
    }
  }

  def self.ate configuration
    Turple::Core.new configuration
  end
end
