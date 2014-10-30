require 'active_support/core_ext/hash/reverse_merge'
require 'recursive-open-struct'

class Turple
  attr_reader :output

  # Allows Turple.ate vs Turple.new
  class << self
    alias_method :ate, :new
  end

private

    def initialize object, data, options = {}
      @old_paths = []
      @object = object
      @type = get_object_type @object
      @data = process_data data
      @options = options.reverse_merge({
        # default file extension of files to interpolate content
        file_ext: '.turple',

        # default regex for path interpolation
        # matches capital underscored data keys ie [FOO.BAR]
        path_regex: /\[([A-Z_.]+)\]/,

        # default regex for content interpolation
        # matches capital underscored data keys ie <>foo.bar<>
        content_regex: /<>([a-z_.]+)<>/
      })

      interpolate @type
    end


    def get_object_type object
      case
      when File.directory?(object)
        :dir
      when File.file?(object)
        :file
      when object.is_a?(String)
        :string
      end
    end

    def interpolate type
      @output = case type
      when :dir
        process_paths
        process_files
        @object
      when :file
        process_files
        @object
      when :string
        process_string @object
      end

      cleanup_old_paths
    end

    # Convert options to OpenStruct so we can use dot notation in the templates
    #
    def process_data data
      RecursiveOpenStruct.new(data)
    end

    # Allow templates to call option values directly
    #
    def method_missing method
      @data.send(method.to_sym) || super
    end

    # Collect files with a matching value to interpolate
    #
    def process_paths
      Dir.glob(File.join(@object, '**/*')).select do |path|
        File.file?(path) && path =~ @options[:path_regex]
      end.each { |path| process_path path }
    end

    # Interpolate filenames with template options
    #
    def process_path file_path
      return unless File.exist? file_path

      # add to old_paths array to delete later
      @old_paths << File.dirname(file_path)

      new_file_path = file_path.gsub @options[:path_regex] do
        # Extract interpolated values into symbols
        methods = $1.downcase.split('.').map(&:to_sym)

        # Call each method on options
        methods.inject(@data){ |options, method| options.send(method.to_sym) }
      end

      # make sure new path exists and move file to it
      newDir = File.dirname new_file_path
      FileUtils.mkdir_p newDir
      FileUtils.mv file_path, new_file_path
    end

    # Collect files with an .erb extension to interpolate
    #
    def process_files
      Dir.glob(File.join(@object, "**/*#{@options[:file_ext]}"), File::FNM_DOTMATCH).each do |file|
        process_file file
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
      FileUtils.mv file, file.chomp(@options[:file_ext])
    end

    def process_string string
      string.gsub! @options[:content_regex] do
        # Extract interpolated values into symbols
        methods = $1.downcase.split('.').map(&:to_sym)

        # Call each method on options
        methods.inject(@data){ |options, method| options.send(method.to_sym) }
      end
    end

    def cleanup_old_paths
      @old_paths.uniq.each do |path|
        FileUtils.rm_f path
      end
    end
end
