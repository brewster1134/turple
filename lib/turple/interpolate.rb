require 'active_support/core_ext/hash/keys'
require 'date'
require 'yaml'

class Turple::Interpolate
  attr_reader :destination

private

  def initialize template, data, destination
    @template_path = template.path
    @configuration = template.configuration
    @data = data.data
    @destination = get_destination destination
    @tmp_dir = Dir.mktmpdir

    process_template! create_tmp_template!
    create_turplefile!
  end

  # create the destination directory if it doesnt not exist
  #
  # @param destination [String] path to a destination to save interpolated template to
  #
  # @return [Pathname] path object to the destination directory
  #
  def get_destination destination
    # raise error if desination directory is not empty
    raise S.ay('Turple | Destination directory is not empty', :error) if Dir.entries(destination).size > 2
    Pathname.new FileUtils.mkdir_p(destination).first
  end

  # Copy template to tmp dir and get the new path
  #
  def create_tmp_template!
    FileUtils.cp_r @template_path, @tmp_dir
    File.join(@tmp_dir, File.basename(@template_path))
  end

  # Collect paths to interpolate
  # Only process files and empty directories
  #
  # @param template_path [String] valid path to a root template directory
  #
  def process_template! template_path
    Find.find template_path do |path|
      # if path is a file...
      # or path is an empty directory
      if File.file?(path) || Dir.entries(path).size <= 2
        process_path! path
      end
    end
  end

  # Interpolate a path
  #
  # @param path [String] a valid path of a template asset
  #
  def process_path! path
    # start the new_path out matching the original path
    new_path = path

    # interpolate file contents
    file_ext_regex = /\.#{Regexp.escape(@configuration[:file_ext])}$/
    if path =~ file_ext_regex
      process_contents! path
    end

    # interpolate path
    path_regex = Regexp.new @configuration[:path_regex]
    if path =~ path_regex
      new_path = path.gsub path_regex do
        # Extract interpolated values into symbols
        methods = $1.downcase.split(@configuration[:path_separator]).map(&:to_sym)

        # Call each method on the data
        methods.inject(@data){ |data, method| data.send(method.to_sym) }
      end
    end

    # Remove the turple file extension from the file name
    new_path.sub! file_ext_regex, ''

    # replace the tmp dir path, with the destination path
    new_path.sub! @tmp_dir, @destination.to_s

    copy_path! path, new_path
  end

  # Open a file, interpolate its contents, and overwrite it with the new contents
  #
  # @param file_path [String]  valid path to a file with contents needing interpolated
  # @return [File]
  #
  def process_contents! file_path
    contents = File.read file_path
    new_contents = process_string! contents

    # Overwrite the original file with the processed file
    File.open file_path, 'w' do |f|
      f.write new_contents
    end
  end

  def process_string! string
    content_regex = Regexp.new @configuration[:content_regex]
    string.gsub content_regex do
      # Extract interpolated values into symbols
      methods = $1.downcase.split(@configuration[:content_separator]).map(&:to_sym)

      # Call each method on data
      methods.inject(@data){ |data, method| data.send(method.to_sym) }
    end
  end

  # Copies a modified path asset to the destination
  #
  # @param path [String] path to the asset in the tmp directory
  # @param new_path [String] path to the new asset to create/copy
  #
  def copy_path! path, new_path
    # if path is an empty directory, just create the directory
    if File.directory? path
      FileUtils.mkdir_p new_path

    # if path is a file, make sure its directory exists and copy the file to it
    elsif File.file? path
      FileUtils.mkdir_p File.dirname(new_path)
      FileUtils.cp_r path, new_path
    end
  end

  # Saves the complete turplefile data to the newly created project
  #
  # @return [File]
  #
  def create_turplefile!
    # get new template name based on the first directory of the destination
    turplefile_path = File.join(Dir[File.join(@destination, '**')].first, 'Turplefile')
    turplefile_object = Turple.turpleobject.merge({
      template: @template_path,
      :created_on => Date.today.to_s
    })

    # convert object to yaml
    turplefile_contents = turplefile_object.deep_stringify_keys.to_yaml

    # Overwrite the original file if it exists with the processed file
    File.open turplefile_path, 'w' do |f|
      f.write turplefile_contents
    end
  end
end
