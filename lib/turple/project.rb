#
# Turple::Project
# Handles the details for the project to be generated
class Turple::Project
  def initialize local_path
    Turple::Core.load_turplefile local_path
  end

  def settings
    Turple::Core.settings[:project]
  end

  def data
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
