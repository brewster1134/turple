require 'active_support/core_ext/hash/deep_merge'
require 'cli_miami'
require 'find'

class Turple::Template
  attr_accessor :path, :required_data

  def self.valid? template_path
    File.exists? File.expand_path template_path
  end

  # Scan a path and determine the required data needed to interpolate it
  # @param template_path [String] path to a template file
  # @return [Hash] a hash of all the data needed
  def self.scan_for_data template_path
    required_data = {}

    Find.find template_path do |path|
      if File.file?(path)

        # process file paths
        if path =~ Turple.configuration[:path_regex]
          capture_groups = path.scan(Turple.configuration[:path_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(Turple.configuration[:path_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            required_data.deep_merge! group_attributes_hash
          end
        end

        # process file contents
        if path =~ Turple.configuration[:file_ext_regex]
          capture_groups = File.read(path).scan(Turple.configuration[:content_regex]).flatten

          capture_groups.each do |group|
            group_attributes = group.split(Turple.configuration[:content_separator])
            group_attributes_hash = group_attributes.reverse.inject(true) { |value, key| { key.downcase.to_sym => value } }

            required_data.deep_merge! group_attributes_hash
          end
        end
      end
    end

    return required_data
  end

private

  def initialize path
    @path = File.expand_path path

    validate
    @required_data = scan_for_data
  end

  def validate
    unless File.exists? @path
      raise S.ay "Turple::Template - Invalid Path - #{@path}", :error
    end
  end

  def prompt_for_template
    template = nil

    until template
      A.sk 'what template?', :readline => true do |response|
        template = response if Turple::Template.valid? File.expand_path response
      end
    end

    template
  end

  def prompt_for_data required_data, provided_data

  end
end
