#
# Turple::Source
#
class Turple::Source
  attr_reader :location

  def initialize location
  end

  def name
  end

  def templates
  end

  # @param template [String]  A template key, or name
  #
  def find_template template
  end

  def self.all
  end

  # @param source [String]  A source key, name, or location
  #
  def self.find source
  end
end

Turple::Source.new 'brewster1134/turple-templates'

# #
# # Turple::Source
# #
# class Turple::Source
#   attr_reader :templates
#
#   # Class instance variable for all registered sources
#   @@sources = Hash.new
#
#   # Attempt to initialize and register a source
#   # @param source_name [String] A unique source name
#   # @param source_location [String] A valid source location (as supported by Sourcerer)
#   #
#   def initialize source_location, source_name = nil
#     # @TODO raise custom error if source with name already exists
#     # Raise if @@sources[source_name]
#
#     # @TODO download/copy source to tmp file
#
#     # @TODO load source Turplefile ?
#
#     # @TODO Collect and initialize all available templates
#
#     # Add source to class instance variable
#     @@sources[source_name] = self
#   end
#
#   # @param template_name [String] Template name to lookup in downloaded source
#   # @return [Turple::Template, false] Turple::Template instance or false if none exists
#   #
#   def get_template_by_name template_name
#     templates[template_name] || false
#   end
#
#   # @return [Array] Array of all registered Turple::Sources
#   #
#   def self.all
#     @@sources.values.sort
#   end
#
#   # @param source_name [String] Source name to lookup in registered sources by key
#   # @return [Turple::Source, false] Turple::Source instance or false if none exists
#   #
#   def self.get_source_by_name source_name
#     @@sources[source_name] || false
#   end
#
#   # @param template_name [String] Template name to look for in all the registered sources
#   # @return [Array] Array of Turple::Sources that contain the given template name
#   #
#   def self.find_sources_by_template_name template_name
#     @@sources.select do |source_name, source|
#       source.find_template_by_name template_name
#     end.values
#   end
#
#   def name
#   end
#
# private
#
#
#
#
#
#
#   module Old
#     attr_reader :template_paths
#
#     # Find a template from multiple sources (unless one is specified)
#     #
#     # @param template_name [String] template name generated from the folder name
#     # @param source_name [String] source name provided from the user's Turplefile
#     #
#     # @return [String] path to the desired template
#     #
#     def self.find_template_path template_name, source_name = nil
#       # if source is specified, target it directly
#       if source_name
#         return @@sources[source_name].template_paths[template_name]
#
#         # otherwise loop through sources until a template is found
#       else
#         @@sources.values.each do |source|
#           return source.template_paths[template_name] || next
#         end
#       end
#
#       return nil
#     end
#
#     private
#
#     @@sources = {}
#
#     def initialize source_name, source_path
#       @template_paths = {}
#       @source = Sourcerer.new(source_path)
#
#       # after source is created
#       add_templates @source
#
#       # add new source to hash
#       @@sources[source_name] = self
#     end
#
#     # search through source and add any directory with a Turplefile as a turple template
#     #
#     # @param source [Sourcerer] A Sourcerer instance object
#     #
#     def add_templates source
#       source.files('**/Turplefile').each do |turplefile_path|
#         template_path = File.dirname(turplefile_path)
#         template_name = File.basename(template_path)
#
#         add_template template_name, template_path
#       end
#     end
#
#     # add a template path to the instance var
#     #
#     # @param template_name [String]
#     # @param template_path [String]
#     #
#     def add_template template_name, template_path
#       @template_paths[template_name] = template_path
#     end
#   end
# end
