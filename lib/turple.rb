class Turple; end

# classes
require 'turple/cli'

class Turple
  class << self
    # Allows Turple.ate vs Turple.new
    alias_method :ate, :new

    def configuration
      @@configuration
    end

    def template
      @@template
    end

    def data
      @@data
    end

    def load_turplefile turplefile_path
      # loop through root keys and store them (data, template, configuration)
    end
  end

  def initialize args
  end
end


# require 'active_support/core_ext/hash/reverse_merge'
# require 'find'
# require 'pathname'
# require 'recursive-open-struct'
# require 'tmpdir'

# class Turple; end

# # modules
# require 'turple/interpolate'
# require 'turple/data'

# # classes
# require 'turple/cli'

# class Turple
#   include Turple::Data
#   include Turple::Interpolate
#   attr_reader :data, :destination, :output

#   # Allows Turple.ate vs Turple.new
#   class << self
#     alias_method :ate, :new
#   end

# private

#     def initialize object, destination, data, options = {}
#       @options = options.reverse_merge({
#         # name of the folder to put processed files into in the tmp dir
#         processed_tmp_dir: 'TURPLEated',

#         # default file extension of files to interpolate content
#         file_ext_regex: /\.turple$/,

#         # default regex for path interpolation
#         # matches capital underscored data keys ie [FOO.BAR]
#         path_regex: /\[([A-Z_.]+)\]/,

#         # default regex for content interpolation
#         # matches capital underscored data keys ie <>foo.bar<>
#         content_regex: /<>([a-z_.]+)<>/
#       })

#       @object = object
#       @tmp_dir = Dir.mktmpdir
#       @tmp_processed_dir = File.join(@tmp_dir, @options[:processed_tmp_dir])
#       copy_to_tmp @object, @tmp_dir

#       @type = get_type @object
#       @destination = get_destination destination
#       @data = get_data data

#       interpolate @type
#       copy_to_destination @destination
#     end

#     # If object is a file system resource (not a string), copy it to a tmp dir for processing
#     #
#     def copy_to_tmp object, tmp_dir
#       if File.exists? object
#         # Copy object to temp file
#         FileUtils.cp_r object, tmp_dir
#       end
#     end

#     # Determine the type of data to process
#     #
#     def get_type object
#       case
#       when File.directory?(object)
#         :dir
#       when File.file?(object)
#         :file
#       when object.is_a?(String)
#         :string
#       end
#     end

#     # Get the destination path for where processed data will be copied to
#     #
#     def get_destination destination
#       case destination
#       when :cwd, :here, :pwd
#         Dir.pwd
#       when String
#         File.expand_path destination
#       else
#         nil
#       end
#     end

#     # Convert options to OpenStruct so we can use dot notation in the templates
#     #
#     def get_data data
#       RecursiveOpenStruct.new(data)
#     end

#     # Allow templates to call option values directly using the open struct api
#     #
#     def method_missing method
#       @data.send(method.to_sym) || super
#     end

#     def copy_to_destination destination
#       if destination
#         # if processing a string and a destination exists, create and write the output the file
#         if @type == :string
#           File.open destination, 'w' do |f|
#             f.write @output
#           end

#         # otherwise we assume its a file or directory that we copy from the tmp dir
#         else
#           # get first entry (should only ever be one anyway) form the processed folder in the tmp dir
#           processed_dir = Dir.glob(File.join(@tmp_processed_dir, "**")).first

#           # Copy to destination
#           FileUtils.cp_r processed_dir, destination
#         end
#       end
#     end
# end
