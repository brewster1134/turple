require 'active_support/core_ext/hash/deep_merge'
require 'cli_miami'
require 'find'

class Turple::Template
  attr_accessor :path, :required_data

  def initialize path
    @path = File.expand_path path

    validate
    @required_data = scan_for_data
  end

private

  def validate
    unless File.exists? @path
      raise S.ay "Turple::Template - Invalid Path - #{@path}", :error
    end
  end

  def scan_for_data
    data = {}

    Find.find @path do |path|
      if File.file?(path)

        # process file paths
        if path =~ Turple.configuration[:path_regex]
          capture_groups = path.scan(Turple.configuration[:path_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(Turple.configuration[:path_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            data.deep_merge! group_attributes_hash
          end
        end

        # process file contents
        if path =~ Turple.configuration[:file_ext_regex]
          capture_groups = File.read(path).scan(Turple.configuration[:content_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(Turple.configuration[:content_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            data.deep_merge! group_attributes_hash
          end
        end
      end
    end

    return data
  end
end
