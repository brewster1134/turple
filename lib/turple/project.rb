#
# Turple::Project
# Handles the details for the project to be generated
class Turple::Project
  attr_reader :name

  # Initialize a new Turple Project
  # @param [Hash] args
  # @option args [String]           :name     Name of the project
  # @option args [String]           :path     Local path to the project directory
  # @option args [Hash]             :data     A hash of all required data for the template
  # @option args [Turple::Template] :template Template to validate data against
  #
  def initialize args
    # validation
    raise Turple::Error.new I18n.t('turple.project.initialize.data_arg_missing') unless args[:data] && args[:data].is_a?(Hash)
    raise Turple::Error.new I18n.t('turple.project.initialize.path_arg_missing') unless args[:path]
    raise Turple::Error.new I18n.t('turple.project.initialize.template_arg_missing') unless args[:template] && args[:template].is_a?(Turple::Template)

    path = Pathname.new(args[:path]).expand_path
    @name = args[:name] || path.basename.to_s.titleize
    data = args[:data].deep_symbolize_keys
    template = args[:template]

    # check for missing data
    missing_data_hash = missing_data template.required_data, data
    unless missing_data_hash.empty?
      raise Turple::Error.new I18n.t('turple.project.initialize.missing_data', missing_data: missing_data_hash.to_s)
    end

    # VALID! ready to create the project!

    # create project if it doesn't exists`
    unless path.exist?
      FileUtils.mkdir_p path
    end

    write_to_turplefile({
      project: {
        name: @name,
        source: template.source.location,
        template: template.name,
        created_on: Time.now.to_s,
        data: data
      }
    })

    interpolate template
  end

  def missing_data required_data, project_data
    required_data - project_data
  end

  def write_to_turplefile settings
  end

  def interpolate template
  end
end

# #
# # Turple::Project
# # Handles the details for the project to be generated
# # @dependency fileutils
# # @dependency pathname
# # @dependency tmpdir
# #
# class Turple::Project
#   # @param [String] Relative or absolute path to the desired project location
#   # @param [Turple::Template] Valid Template object
#   #
#   def initialize project_path#, template
#     @tmp_path = get_tmp_path
#     @final_path = get_final_path project_path, template.name
#   end
#
#   def data
#   end
#
# private
#
#   # Create tmp folder to interpolate to
#   #
#   def get_tmp_path
#     Pathname.new Dir.mktmpdir
#   end
#
#   # Directory to save project
#   # If project name is not passed by user, create a name based on the template used
#   #
#   def get_final_path user_path, template_name
#     # Convert user path, or generated path to absolute path & create directory
#     absolute_project_path = if user_path
#       File.expand_path user_path
#     else
#       project_dir_name = dir_from_template_name template_name
#       File.expand_path project_dir_name
#     end
#
#     # Create project directory
#     FileUtils.mkdir_p absolute_project_path
#
#     # Return pathname
#     Pathname.new absolute_project_path
#   end
#
#   # Get the project name based on the template used (from i18n)
#   # @param [String, Symbol] The name of the template used to create this project
#   #
#   def dir_from_template_name template_name
#     # Convert template name to lowercase, hyphenated, and with `-template` removed if it exists.
#     template_dir_name = template_name.to_s.titleize.parameterize.dasherize.gsub('-template', '')
#
#     # Gets project name from i18n
#     I18n.t 'turple.project.default_name', template_name: template_dir_name
#   end
# end
