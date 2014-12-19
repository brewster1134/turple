require 'active_support/core_ext/hash/keys'
require 'date'
require 'yaml'

class Turple::Interpolate
  attr_reader :destination

private

  def initialize template, data, destination
    @template = template
    @data = data
    @destination = get_destination destination
    @configuration = @template.configuration

    @tmp_dir = Dir.mktmpdir
    @tmp_template_path = copy_to_temp

    process_template! @tmp_template_path

    save_turplefile
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

  # copy template to tmp dir and get the new path
  def copy_to_temp
    FileUtils.cp_r @template.path, @tmp_dir
    File.join(@tmp_dir, File.basename(@template.path))
  end

  # Collect paths to interpolate
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

  # Interpolate filenames with template options
  #
  def process_path! path
    # process file contents first
    if path =~ /\.#{Regexp.escape(@configuration[:file_ext])}$/
      process_contents! path
    end

    path_regex = Regexp.new @configuration[:path_regex]
    if path =~ path_regex
      new_path = path.gsub path_regex do
        # Extract interpolated values into symbols
        methods = $1.downcase.split(@configuration[:path_separator]).map(&:to_sym)

        # Call each method on the data
        methods.inject(@data.data){ |data, method| data.send(method.to_sym) }
      end

      move_path path, new_path
    else
      move_path path
    end
  end

  # Interpolate erb template data
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
      methods.inject(@data.data){ |data, method| data.send(method.to_sym) }
    end
  end

  # create and copy the processed path to the destination
  def move_path path, new_path = nil
    # set new_path to the same path if just need to move a file straight across without interpolation
    new_path = path unless  new_path

    # Remove the turple file extension from the file name
    new_path.sub! /\.#{Regexp.escape(@configuration[:file_ext])}$/, ''

    # Replace the tmp dir path, with the destination path
    new_path.sub! @tmp_dir, @destination.to_s

    # create new directory, and copy files
    if File.directory? path
      FileUtils.mkdir_p new_path

    elsif File.file? path
      FileUtils.mkdir_p File.dirname(new_path)
      FileUtils.cp_r path, new_path
    end
  end

  def save_turplefile
    # get new template name based on the first directory of the destination
    turplefile_path = File.join(Dir[File.join(@destination, '**')].first, 'Turplefile')
    turplefile_object = Turple.turpleobject.merge({
      template: @template.path,
      :created_on => Date.today.to_s
    })

    # convert object to yaml
    turplefile_contents = turplefile_object.deep_stringify_keys.to_yaml
    puts turplefile_path, turplefile_object, turplefile_contents

    # Overwrite the original file if it exists with the processed file
    File.open turplefile_path, 'w' do |f|
      f.write turplefile_contents
    end
  end
end
