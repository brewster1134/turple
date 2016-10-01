require 'turple/cli'

describe Turple::Cli do
  #
  # SETUP
  #
  before do
    @cli = Turple::Cli.new
    @ask_instance = instance_double CliMiami::A
    @source_instance = instance_double Turple::Source
    @template_instance = instance_double Turple::Template
    @project_instance = instance_double Turple::Project
    @data_instance = instance_double Turple::Data

    allow(@cli).to receive(:ask_user_for_data).and_return @data_instance
    allow(@cli).to receive(:ask_user_for_project).and_return @project_instance
    allow(@cli).to receive(:ask_user_for_source_or_template).and_return @template_instance
    allow(@cli).to receive(:ask_user_for_source).and_return @source_instance
    allow(@cli).to receive(:ask_user_for_template).and_return Turple::Template.allocate
    allow(@cli).to receive(:show_user_templates)
    allow(@source_instance).to receive(:name).and_return 'Source Name'
    allow(@source_instance).to receive(:templates).and_return [Turple::Template.allocate]
    allow(@template_instance).to receive(:source).and_return @source_instance

    allow(CliMiami::A).to receive(:sk).and_return @ask_instance
    allow(Turple::Core).to receive(:new)
    allow(Turple::Core).to receive(:project).and_return @project_instance
    allow(Turple::Core).to receive(:template).and_return @template_instance
    allow(Turple::Source).to receive(:all).and_return [@source_instance]
    allow(Turple::Source).to receive(:new).and_return Turple::Source.allocate
    allow_any_instance_of(Turple::Template).to receive(:name).and_return 'Template Name'
  end

  #
  # TEARDOWN
  #
  after :each do
    allow(@cli).to receive(:ask_user_for_data).and_call_original
    allow(@cli).to receive(:ask_user_for_project).and_call_original
    allow(@cli).to receive(:ask_user_for_source_or_template).and_call_original
    allow(@cli).to receive(:ask_user_for_source).and_call_original
    allow(@cli).to receive(:ask_user_for_template).and_call_original
    allow(@cli).to receive(:show_user_templates).and_call_original
  end

  after do
    allow(CliMiami::A).to receive(:sk).and_call_original
    allow(Turple::Core).to receive(:new).and_call_original
    allow(Turple::Core).to receive(:project).and_call_original
    allow(Turple::Core).to receive(:template).and_call_original
    allow(Turple::Source).to receive(:all).and_call_original
    allow(Turple::Source).to receive(:new).and_call_original
    allow_any_instance_of(Turple::Template).to receive(:name).and_call_original
  end

  #
  # THOR METHODS
  #
  describe '#ate' do
    before do
      allow(@cli).to receive(:ate).and_call_original
      @cli.ate
    end

    it 'should prompt user for action and start Turple' do
      expect(@cli).to have_received(:ask_user_for_source_or_template).ordered
      expect(@cli).to have_received(:ask_user_for_project).ordered
      expect(@cli).to have_received(:ask_user_for_data).with(@template_instance, @project_instance).ordered
      expect(Turple::Core).to have_received(:new).with({
        source: @source_instance,
        template: @template_instance,
        project: @project_instance,
        data: @data_instance
      }).ordered
    end
  end

  #
  # INSTANCE METHODS
  #
  describe '.ask_user_for_source_or_template' do
    before do
      allow(@cli).to receive(:ask_user_for_source_or_template).and_call_original
      @cli_method_calls = []

      allow(@ask_instance).to receive(:value).and_return(
        [:source],
        [:source],
        [:template]
      )

      allow(@cli).to receive(:show_user_templates) do
        @cli_method_calls << :show_user_templates
      end

      allow(@cli).to receive(:ask_user_for_source) do
        @cli_method_calls << :ask_user_for_source
      end

      allow(@cli).to receive(:ask_user_for_template) do
        @cli_method_calls << :ask_user_for_template
      end.and_return Turple::Template.allocate

      @template = @cli.ask_user_for_source_or_template
    end


    it 'should allow adding multiple sources, and end with choosing a template' do
      expect(@cli_method_calls).to eq [
        :show_user_templates,
        :ask_user_for_source,
        :show_user_templates,
        :ask_user_for_source,
        :show_user_templates,
        :ask_user_for_template
      ]
    end

    it 'should return a Turple Template' do
      expect(@template).to be_a Turple::Template
    end
  end

  describe '.ask_user_for_source' do
    before do
      allow(@cli).to receive(:ask_user_for_source).and_call_original
    end

    context 'when entering a source location' do
      before do
        @souce_new_args = []

        allow(@ask_instance).to receive(:value).and_return 'invalid_source', 'valid_source'

        allow(Turple::Source).to receive(:new) do |arg|
          @souce_new_args << arg
        end.and_return nil, Turple::Source.allocate

        @source = @cli.ask_user_for_source
      end

      it 'should prompt until a valid source is created' do
        expect(@ask_instance).to have_received(:value).twice
        expect(Turple::Source).to have_received(:new).twice
        expect(@souce_new_args).to eq [ 'invalid_source', 'valid_source' ]
        expect(@source).to be_a Turple::Source
      end
    end

    context 'when exiting' do
      before do
        allow(@ask_instance).to receive(:value).and_return ''

        @source = @cli.ask_user_for_source
      end

      it 'should allow not entering a source' do
        expect(@ask_instance).to have_received(:value)
        expect(Turple::Source).to_not have_received(:new)
        expect(@source).to be_nil
      end
    end
  end

  describe '.ask_user_for_template' do
    before do
      allow(@cli).to receive(:ask_user_for_template).and_call_original
    end

    context 'when selecting a template' do
      before do
        allow(@ask_instance).to receive(:value).and_return ['Source Name#Template Name']

        @template = @cli.ask_user_for_template
      end

      it 'should show user templates, and prompt for selection' do
        expect(@ask_instance).to have_received(:value).ordered
        expect(@template).to be_a Turple::Template
      end
    end

    context 'when exiting' do
      before do
        allow(@ask_instance).to receive(:value).and_return ['']

        @template = @cli.ask_user_for_template
      end

      it 'should show user templates, and allow not selecting a template' do
        expect(@template).to be_nil
      end
    end
  end

  describe '.ask_user_for_project' do
    before do
      allow(@cli).to receive(:ask_user_for_project).and_call_original

      @cli_method_calls = []

      allow(@ask_instance).to receive(:value) do |arg|
        @cli_method_calls << :ask_value
      end.and_return 'invalid_project_path', 'valid_project_path'

      allow(Turple::Project).to receive(:new) do |arg|
        @cli_method_calls << :project_new
      end.and_return nil, Turple::Project.allocate

      @project = @cli.ask_user_for_project
    end

    it 'shoud prompt until valid project' do
      expect(@cli_method_calls).to eq [
        :ask_value,
        :project_new,
        :ask_value,
        :project_new
      ]
    end

    it 'should return a Turple Template' do
      expect(@ask_instance).to have_received(:value).twice
      expect(@project).to be_a Turple::Project
    end
  end

  describe '.ask_user_for_data' do
    before do
      allow(@cli).to receive(:ask_user_for_data).and_call_original
      allow(@cli).to receive(:ask_user_for_data_from_hash)

      allow(@template_instance).to receive(:required_data).and_return :required_data
      allow(@template_instance).to receive(:required_data_descriptions).and_return :required_data_descriptions
      allow(@project_instance).to receive(:data).and_return :existing_data

      @cli.ask_user_for_data @template_instance, @project_instance
    end

    it 'should collect data' do
      expect(@cli).to have_received(:ask_user_for_data_from_hash).with :required_data, :required_data_descriptions, :existing_data
    end
  end

  describe '.ask_user_for_data_from_hash' do
    before do
      allow(@cli).to receive(:ask_user_for_data_from_hash).and_call_original

      @required_data = {
        var: nil,
        existing_var: nil,
        nested: {
          var: nil,
          missing_description: nil
        }
      }

      @required_data_descriptions = {
        var: 'What is var?',
        existing_var: 'What is existing var?',
        nested: {
          var: 'What is nested var?'
        }
      }

      @existing_data = {
        existing_var: 'EXISTING VAR',
        extra_var: 'EXTRA VAR'
      }

      @completed_data = {
        var: 'VAR',
        existing_var: 'EXISTING VAR',
        nested: {
          var: 'NESTED VAR',
          missing_description: 'NESTED MISSING DESCRIPTION'
        }
      }

      allow(@cli).to receive(:ask_user_for_data_from_description).and_return 'VAR', 'NESTED VAR', 'NESTED MISSING DESCRIPTION'

      @data = @cli.ask_user_for_data_from_hash @required_data, @required_data_descriptions, @existing_data
    end

    it 'should prompt user for missing data' do
      expect(@cli).to have_received(:ask_user_for_data_from_hash).exactly(2).times
      expect(@cli).to have_received(:ask_user_for_data_from_description).exactly(3).times
    end

    it 'should return a hash' do
      expect(@data).to eq @completed_data
    end
  end

  describe '.ask_user_for_data_from_description' do
    before do
      allow(@cli).to receive(:ask_user_for_data_from_description).and_call_original

      allow(@ask_instance).to receive(:value).and_return '', 'John'

      @cli_method_calls = []
      allow(CliMiami::A).to receive(:sk) do |arg|
        @cli_method_calls << arg
      end.and_return @ask_instance

      @value = @cli.ask_user_for_data_from_description 'Name'
    end

    it 'should prompt user for a value' do
      expect(@cli_method_calls).to eq ['Name', 'Name']
    end

    it 'should return the users value' do
      expect(@value).to eq 'John'
    end
  end
end
