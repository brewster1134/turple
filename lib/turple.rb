require 'active_support/core_ext/hash/reverse_merge'
require 'find'
require 'pathname'
require 'recursive-open-struct'
require 'tmpdir'

class Turple
  attr_reader :data, :destination, :output

  # Allows Turple.ate vs Turple.new
  class << self
    alias_method :ate, :new
  end

private

    def initialize object, destination, data, options = {}
      @options = options.reverse_merge({
        # name of the folder to put processed files into in the tmp dir
        processed_tmp_dir: 'TURPLEated',

        # default file extension of files to interpolate content
        file_ext_regex: /\.turple$/,

        # default regex for path interpolation
        # matches capital underscored data keys ie [FOO.BAR]
        path_regex: /\[([A-Z_.]+)\]/,

        # default regex for content interpolation
        # matches capital underscored data keys ie <>foo.bar<>
        content_regex: /<>([a-z_.]+)<>/
      })

      @object = object
      @tmp_dir = Dir.mktmpdir
      @tmp_processed_dir = File.join(@tmp_dir, @options[:processed_tmp_dir])
      copy_to_tmp @object, @tmp_dir

      @type = get_type @object
      @destination = get_destination destination
      @data = get_data data

      interpolate @type
      copy_to_destination @destination
    end

    # If object is a file system resource (not a string), copy it to a tmp dir for processing
    #
    def copy_to_tmp object, tmp_dir
      if File.exists? object
        # Copy object to temp file
        FileUtils.cp_r object, tmp_dir
      end
    end

    # Determine the type of data to process
    #
    def get_type object
      case
      when File.directory?(object)
        :dir
      when File.file?(object)
        :file
      when object.is_a?(String)
        :string
      end
    end

    # Get the destination path for where processed data will be copied to
    #
    def get_destination destination
      case destination
      when :cwd, :here, :pwd
        Dir.pwd
      when String
        File.expand_path destination
      else
        nil
      end
    end

    # Convert options to OpenStruct so we can use dot notation in the templates
    #
    def get_data data
      RecursiveOpenStruct.new(data)
    end

    # Allow templates to call option values directly using the open struct api
    #
    def method_missing method
      @data.send(method.to_sym) || super
    end

    # handle the process of the object
    #
    def interpolate type
      case type
      when :dir
        process_paths
        process_files
      when :file
        process_paths
        process_files
      when :string
        process_string @object
      end
    end

    def copy_to_destination destination
      if destination
        # if processing a string and a destination exists, create and write the output the file
        if @type == :string
          File.open destination, 'w' do |f|
            f.write @output
          end

        # otherwise we assume its a file or directory that we copy from the tmp dir
        else
          # get first entry (should only ever be one anyway) form the processed folder in the tmp dir
          processed_dir = Dir.glob(File.join(@tmp_processed_dir, "**")).first

          # Copy to destination
          FileUtils.cp_r processed_dir, destination
        end
      end
    end

    # Collect files with a matching value to interpolate
    #
    def process_paths
      Find.find @tmp_dir do |path|
        # dont process tmp dir
        next if path == @tmp_dir

        # process files that match interpolation syntax
        if File.file?(path) && path =~ @options[:path_regex]
          process_path path
        end
      end
    end

    # Interpolate filenames with template options
    #
    def process_path file_path
      new_file_path = file_path.gsub @options[:path_regex] do
        # Extract interpolated values into symbols
        methods = $1.downcase.split('.').map(&:to_sym)

        # Call each method on options
        methods.inject(@data){ |options, method| options.send(method.to_sym) }
      end

      # modify the path to point to the processed sub directory
      new_file_path.gsub! @tmp_dir, @tmp_processed_dir

      # create and copy the process file path to the new tmp dir
      if File.directory? file_path
        FileUtils.mkdir_p new_file_path
      elsif File.file? file_path
        FileUtils.mkdir_p File.dirname(new_file_path)
      end

      FileUtils.cp file_path, new_file_path
    end

    # Collect files with an .erb extension to interpolate
    #
    def process_files
      Find.find @tmp_processed_dir do |path|
        # dont process tmp dir
        next if path == @tmp_processed_dir

        if File.file?(path) && path =~ @options[:file_ext_regex]
          process_file path
        end
      end
    end

    # Interpolate erb template data
    #
    def process_file file
      contents = File.read file
      new_contents = process_string contents

      # Overwrite the original file with the processed file
      File.open file, 'w' do |f|
        f.write new_contents
      end

      # Remove the .erb from the file name
      FileUtils.mv file, file.sub(@options[:file_ext_regex], '')
    end

    def process_string string
      string.gsub! @options[:content_regex] do
        # Extract interpolated values into symbols
        methods = $1.downcase.split('.').map(&:to_sym)

        # Call each method on options
        methods.inject(@data){ |options, method| options.send(method.to_sym) }
      end

      # if string is not getting saved to a file, assign it to the output var
      @output = string if @type == :string

      return string
    end
end
