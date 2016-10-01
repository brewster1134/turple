class Turple::Template
  def name
  end

  def required_data
  end

  def required_data_descriptions
  end
end

# # require 'active_support/core_ext/hash/deep_merge'
# # require 'cli_miami'
# # require 'find'
# # require 'sourcerer'
#
# class Turple::Template
#   def initialize template_path
#     # @TODO set source to source instance object
#   end
#
#   def source
#   end
#
#   def name
#   end
#
#   def required_data
#   end
#
#   def required_data_descriptions
#   end
#
#   def get_missing_data
#     allow(@template_instance).to receive(:data).and_return({
#       data_keys: {
#         foo_key: :foo_var,
#         bar_key: :bar_var,
#         nested: {
#           nested_foo_key: :nested_foo_var,
#           nested_bar_key: :nested_bar_var
#         }
#       },
#       data_descriptions: {
#         foo_key: 'foo_description',
#         bar_key: 'bar_description',
#         nested: {
#           nested_foo_key: 'nested_foo_description',
#           nested_bar_key: 'nested_bar_description'
#         }
#       }
#       })
#   end
#
# private
#
#
#
#   module Old
#     SOURCE_TEMPLATE_SPLITTER = '##'
#     attr_accessor :configuration, :name, :path, :required_data
#
#     private
#
#     def initialize template, interactive = false
#       path = get_template_path template
#
#       # validate and set path before configuration
#       if valid_path? path
#         @path = path
#       else
#         if interactive
#           until @path
#             prompt_for_path
#           end
#         else
#           raise S.ay "Invalid Template Path `#{path}`", :turple_error
#         end
#       end
#
#       # with a valid path, load the turplefile
#       Turple.load_turplefile File.join(@path, 'Turplefile')
#
#       # validate configuration after path is validated and template Turplefile is loaded
#       valid_configuration? Turple.configuration
#
#       # set variables after validating path
#       @name = template
#       @required_data = scan_for_data @path
#     end
#
#     # Look for a template path with a user provided template name or path
#     #
#     # @param template [String] template name, source && template name, or system path
#     # @return [String] valid template path or nil if none is found
#     #
#     def get_template_path template
#       return nil unless template
#
#       # with source included in template path...
#       if template.include? SOURCE_TEMPLATE_SPLITTER
#         # split source from template
#         source_template = template.split SOURCE_TEMPLATE_SPLITTER
#
#         # create new source
#         begin
#           source = Turple::Source.new source_template[1], source_template[0]
#         rescue
#           return nil
#         end
#
#         # look up template path from new source
#         source.template_paths[source_template[1]]
#
#         # if just the template name/path is passed...
#       else
#         # check for template name in existing sources or treat it as a local path
#         Turple::Source.find_template_path(template) || File.expand_path(template) || nil
#       end
#     end
#
#     # Scan a path and determine the required data needed to interpolate it
#     #
#     # @param template_path [String] path to a template file
#     # @return [Hash] a hash of all the data needed
#     #
#     def scan_for_data template_path
#       configuration = Turple.configuration
#       required_data = {}
#
#       Find.find template_path do |path|
#         if File.file?(path)
#
#           # process file paths
#           path_regex = Regexp.new configuration[:path_regex]
#           if path =~ path_regex
#             capture_groups = path.scan(path_regex).flatten
#
#             capture_groups.each do |group|
#               group_attributes = group.split(configuration[:path_separator])
#               group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }
#
#               required_data.deep_merge! group_attributes_hash
#             end
#           end
#
#           # process file contents
#           content_regex = Regexp.new configuration[:content_regex]
#           if path =~ /\.#{Regexp.escape(configuration[:file_ext])}$/
#             capture_groups = File.read(path).scan(content_regex).flatten
#
#             capture_groups.each do |group|
#               group_attributes = group.split(configuration[:content_separator])
#               group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }
#
#               required_data.deep_merge! group_attributes_hash
#             end
#           end
#         end
#       end
#
#       # check that the template requires data
#       if required_data.empty?
#         S.ay 'No Required Data - Nothing found to interpolate.  Make sure your configuration matches your template.', :turple_error
#         exit
#       end
#
#       return required_data
#     end
#
#     # prompt the user for a template path until a vaid one is entered
#     # @return [String] valid template path
#     #
#     def prompt_for_path
#       A.sk 'Enter a path to a Turple Template', :preset => :turple_prompt, :readline => true do |response|
#         path = get_template_path response
#         @path = path if valid_path? path
#       end
#     end
#
#     # Check that a path is a valid template
#     #
#     # @param path [String] file system path to a proposed template directory
#     # @return [Boolean]
#     #
#     def valid_path? path
#       !path.nil? && File.directory?(path) && File.file?(File.join(path, 'Turplefile'))
#     end
#
#     # check the configuration is valid
#     #
#     # @param [Hash] a configuration hash
#     # @return [Boolean] true or exit
#     #
#     def valid_configuration? configuration
#       begin
#         # check that a configuration exists
#         if configuration.empty?
#           raise S.ay 'No Configuration Found', :turple_error
#         end
#
#         # check that a configuration values are valid
#         #
#         # make sure the string is a valid extension with no period's in it
#         if !configuration[:file_ext].is_a?(String) ||
#           configuration[:file_ext] =~ /\./
#           raise S.ay "`file_ext` is invalid.  See README for requirements.", :turple_error
#         end
#
#         if !configuration[:path_separator].is_a?(String)
#           raise S.ay "`path_separator` is invalid.  See README for requirements.", :turple_error
#         end
#
#         if !configuration[:content_separator].is_a?(String)
#           raise S.ay "`content_separator` is invalid.  See README for requirements.", :turple_error
#         end
#
#         # make sure it contains the path separator in the capture group
#         if !(configuration[:path_regex] =~ /\(.*#{Regexp.escape(configuration[:path_separator])}.*\)/)
#           raise S.ay "`path_regex` invalid.  See README for requirements.", :turple_error
#         end
#
#         # make sure it contains the path separator in the capture group
#         if !(configuration[:content_regex] =~ /\(.*#{Regexp.escape(configuration[:content_separator])}.*\)/)
#           raise S.ay "`content_regex` invalid.  See README for requirements.", :turple_error
#         end
#
#         return true
#       rescue
#         exit
#       end
#     end
#   end
# end
