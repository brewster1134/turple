# module Turple::Interpolate
#   # handle the process of the object
#   #
#   def interpolate type
#     case type
#     when :dir
#       process_paths
#       process_files
#     when :file
#       process_paths
#       process_files
#     when :string
#       process_string @object
#     end
#   end

# private

#     # Collect files with a matching value to interpolate
#     #
#     def process_paths
#       Find.find @tmp_dir do |path|
#         # dont process tmp dir
#         next if path == @tmp_dir

#         # process files that match interpolation syntax
#         if File.file?(path) && path =~ @options[:path_regex]
#           process_path path
#         end
#       end
#     end

#     # Interpolate filenames with template options
#     #
#     def process_path file_path
#       new_file_path = file_path.gsub @options[:path_regex] do
#         # Extract interpolated values into symbols
#         methods = $1.downcase.split('.').map(&:to_sym)

#         # Call each method on options
#         methods.inject(@data){ |options, method| options.send(method.to_sym) }
#       end

#       # modify the path to point to the processed sub directory
#       new_file_path.gsub! @tmp_dir, @tmp_processed_dir

#       # create and copy the process file path to the new tmp dir
#       if File.directory? file_path
#         FileUtils.mkdir_p new_file_path
#       elsif File.file? file_path
#         FileUtils.mkdir_p File.dirname(new_file_path)
#       end

#       FileUtils.cp file_path, new_file_path
#     end

#     # Collect files with an .erb extension to interpolate
#     #
#     def process_files
#       Find.find @tmp_processed_dir do |path|
#         # dont process tmp dir
#         next if path == @tmp_processed_dir

#         if File.file?(path) && path =~ @options[:file_ext]
#           process_file path
#         end
#       end
#     end

#     # Interpolate erb template data
#     #
#     def process_file file
#       contents = File.read file
#       new_contents = process_string contents

#       # Overwrite the original file with the processed file
#       File.open file, 'w' do |f|
#         f.write new_contents
#       end

#       # Remove the .erb from the file name
#       FileUtils.mv file, file.sub(@options[:file_ext], '')
#     end

#     def process_string string
#       string.gsub! @options[:content_regex] do
#         # Extract interpolated values into symbols
#         methods = $1.downcase.split('.').map(&:to_sym)

#         # Call each method on options
#         methods.inject(@data){ |options, method| options.send(method.to_sym) }
#       end

#       # if string is not getting saved to a file, assign it to the output var
#       @output = string if @type == :string

#       return string
#     end

# end
