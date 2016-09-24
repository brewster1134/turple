require 'turple/cli'

describe Turple::Cli do
  before do
    @cli = Turple::Cli.new
    @ask_instance = instance_double CliMiami::A
    @source_instance = instance_double Turple::Source
    @template_instance = instance_double Turple::Template
    @project_instance = instance_double Turple::Project
    @data_instance = instance_double Turple::Data

    allow(@source_instance).to receive(:get_template_by_name).and_return Turple::Template.allocate
    allow(@template_instance).to receive(:source).and_return @source_instance
    allow(CliMiami::A).to receive(:sk).and_return @ask_instance
    allow(Turple::Core).to receive(:new)
    allow(Turple::Source).to receive(:get_source_by_name).and_return @source_instance
    allow(Turple::Source).to receive(:new).and_return Turple::Source.allocate
  end

  after do
    allow(CliMiami::A).to receive(:sk).and_call_original
    allow(Turple::Core).to receive(:new).and_call_original
    allow(Turple::Source).to receive(:get_source_by_name).and_call_original
    allow(Turple::Source).to receive(:new).and_call_original
  end

  describe '#ate' do
    before do
      allow(@cli).to receive(:ask_user_for_source_or_template).and_return @template_instance
      allow(@cli).to receive(:ask_user_for_project).and_return @project_instance
      allow(@cli).to receive(:ask_user_for_data).and_return @data_instance

      @cli.ate
    end

    after do
      allow(@cli).to receive(:ask_user_for_source_or_template).and_call_original
      allow(@cli).to receive(:ask_user_for_project).and_call_original
      allow(@cli).to receive(:ask_user_for_data).and_call_original
    end

    it 'should prompt user for action and start Turple' do
      expect(@cli).to have_received(:ask_user_for_source_or_template).ordered
      expect(@cli).to have_received(:ask_user_for_project).ordered
      expect(@cli).to have_received(:ask_user_for_data).ordered
      expect(Turple::Core).to have_received(:new).with({
        source: @source_instance,
        template: @template_instance,
        project: @project_instance,
        data: @data_instance
      }).ordered
    end
  end

  describe '.ask_user_for_source_or_template' do
    before do
      @cli_method_calls = []

      allow(@cli).to receive(:show_user_templates)

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

    after do
      allow(@cli).to receive(:show_user_templates).and_call_original
      allow(@cli).to receive(:ask_user_for_source).and_call_original
      allow(@cli).to receive(:ask_user_for_template).and_call_original
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
      allow(@cli).to receive(:show_user_templates)
    end

    context 'when selecting a template' do
      before do
        allow(@ask_instance).to receive(:value).and_return 'source_name#template_name'

        @template = @cli.ask_user_for_template
      end

      it 'should show user templates, and prompt for selection' do
        expect(@cli).to have_received(:show_user_templates).ordered
        expect(@ask_instance).to have_received(:value).ordered
        expect(Turple::Source).to have_received(:get_source_by_name).with('source_name').ordered
        expect(@source_instance).to have_received(:get_template_by_name).with('template_name').ordered
        expect(@template).to be_a Turple::Template
      end
    end

    context 'when exiting' do
      before do
        allow(@ask_instance).to receive(:value).and_return ''

        @template = @cli.ask_user_for_template
      end

      it 'should show user templates, and allow not selecting a template' do
        expect(@cli).to have_received(:show_user_templates).ordered
        expect(@template).to be_nil
      end
    end
  end

  describe '.ask_user_for_project' do

  end
end
