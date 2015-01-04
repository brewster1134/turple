require 'sourcerer'

class Turple::Source
  attr_reader :template_paths

  # find a template from multiple sources (unless one is specified)
  #
  # @param template_name [String] template name generated from the folder name
  # @param source_name [String] source name provided from the user's Turplefile
  #
  # @return [String] path to the desired template
  #
  def self.find_template_path template_name, source_name = nil
    # if source is specified, target it directly
    if source_name
      return @@sources[source_name].template_paths[template_name]

    # otherwise loop through sources until a template is found
    else
      @@sources.values.each do |source|
        return source.template_paths[template_name] || next
      end
    end

    return nil
  end

private

  @@sources = {}

  def initialize source_name, source_path
    @template_paths = {}
    @source = Sourcerer.new(source_path)

    add_templates @source.destination

    # add new source to hash
    @@sources[source_name] = self
  end

  # search through source and add any directory with a Turplefile as a turple template
  #
  # @param source_path [String] a path to a source.  this will be a generated tmp dir from Sourcerer
  #
  def add_templates source_path
    @source.files('**/Turplefile').each do |turplefile_path|
      template_path = File.dirname(turplefile_path)
      template_name = File.basename(template_path)

      add_template template_name, template_path
    end
  end

  # add a template path to the instance var
  #
  # @param template_name [String]
  # @param template_path [String]
  #
  def add_template template_name, template_path
    @template_paths[template_name] = template_path
  end
end
