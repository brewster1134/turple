require 'turple/cli'

describe Turple::Cli do
  before do
    @cli = Turple::Cli.new
    @ask_instance = instance_double CliMiami::A
    @project_instance = Turple::Project.allocate
    @source_instance = Turple::Source.allocate
    @template_instance = Turple::Template.allocate
    allow(CliMiami::A).to receive(:sk).and_return @ask_instance
  end

  after do
    allow(CliMiami::A).to receive(:sk).and_call_original
    allow(CliMiami::S).to receive(:ay).and_call_original
    allow(FileUtils).to receive(:mkdir_p).and_call_original
    allow(Turple::Core).to receive(:load_turplefile).and_call_original
    allow(Turple::Core).to receive(:new).and_call_original
    allow(Turple::Core).to receive(:settings).and_call_original
    allow(Turple::Project).to receive(:new).and_call_original
    allow(Turple::Source).to receive(:all).and_call_original
    allow(Turple::Source).to receive(:new).and_call_original
  end

  # THOR METHODS
  #
  describe '#ate' do
    before do
      allow(Turple::Core).to receive :load_turplefile
      allow(Turple::Core).to receive :new
      allow(@cli).to receive(:ask_user_for_source_or_template).and_return @template_instance
      allow(@cli).to receive(:ask_user_for_project).and_return @project_instance

      @cli.ate
    end

    it 'should prompt user for action and start Turple' do
      expect(Turple::Core).to have_received(:load_turplefile).with(ENV['HOME']).ordered
      expect(@cli).to have_received(:ask_user_for_source_or_template).ordered
      expect(@cli).to have_received(:ask_user_for_project).with(@template_instance).ordered
      expect(Turple::Core).to have_received(:new).with({
        template: @template_instance,
        project: @project_instance
      }).ordered
    end
  end

  # INSTANCE METHODS
  #
  describe '#ask_user_for_source_or_template' do
    before do
      # simulate adding a source by returning 1 source on the 1st call, and 2 sources on the 2nd call
      allow(Turple::Source).to receive(:all).and_return [
        @source_instance
      ], [
        @source_instance,
        @source_instance
      ]

      allow(@source_instance).to receive(:name).and_return(
        'Source 1',
        'Source 1',
        'Source 2'
      )

      allow(@source_instance).to receive(:templates).and_return [
        @template_instance,
        @template_instance
      ], [
        @template_instance,
        @template_instance
      ], [
        @template_instance
      ]

      allow(@template_instance).to receive(:name).and_return(
        'Source 1 Template 1',
        'Source 1 Template 2',
        'Source 1 Template 1',
        'Source 1 Template 2',
        'Source 2 Template 1'
      )

      @call_order = []

      allow(@ask_instance).to receive(:value) do
        @call_order << :ask_user
      end.and_return [:source], [:template]

      allow(CliMiami::S).to receive(:ay) do |arg|
        @call_order << arg
      end

      allow(@cli).to receive(:ask_user_for_source) do
        @call_order << :ask_user_for_source
      end

      allow(@cli).to receive(:ask_user_for_template) do
        @call_order << :ask_user_for_template
      end.and_return @template_instance

      @template = @cli.ask_user_for_source_or_template
    end

    it 'should allow user to add a new sources and finish with choosing a template' do
      expect(@call_order).to eq [
        'Source 1',
        'Source 1 Template 1',
        'Source 1 Template 2',
        :ask_user,
        :ask_user_for_source,
        'Source 1',
        'Source 1 Template 1',
        'Source 1 Template 2',
        'Source 2',
        'Source 2 Template 1',
        :ask_user,
        :ask_user_for_template
      ]
    end

    it 'should return a Turple Template' do
      expect(@template).to eq @template_instance
    end
  end

  describe '#ask_user_for_source' do
    context 'when entering a source location' do
      before do
        @call_order = []
        allow(Turple::Source).to receive(:new) do |arg|
          @call_order << arg
        end.and_return nil, @source_instance

        allow(@ask_instance).to receive(:value).and_return 'invalid_source', 'valid_source'

        @source = @cli.ask_user_for_source
      end

      it 'should prompt until a valid source is created' do
        expect(@ask_instance).to have_received(:value).twice
        expect(Turple::Source).to have_received(:new).twice
        expect(@call_order).to eq [ 'invalid_source', 'valid_source' ]
      end

      it 'should return a Turple Source' do
        expect(@source).to eq @source_instance
      end
    end

    context 'when exiting' do
      before do
        allow(@ask_instance).to receive(:value).and_return ''
        allow(Turple::Source).to receive(:new)

        @source = @cli.ask_user_for_source
      end

      it 'should allow not entering a source' do
        expect(@ask_instance).to have_received(:value)
        expect(Turple::Source).to_not have_received(:new)
      end

      it 'should not return a Turple Source' do
        expect(@source).to be_nil
      end
    end
  end

  describe '#ask_user_for_template' do
    before do
      @call_order = []
      allow(CliMiami::S).to receive(:ay) do |arg|
        @call_order << arg
      end

      allow(@ask_instance).to receive(:value).and_return ['1']
      allow(@source_instance).to receive(:templates).and_return [@template_instance]
      allow(@source_instance).to receive(:name).and_return 'Source Name'
      allow(@template_instance).to receive(:name).and_return 'Template Name'
      allow(Turple::Source).to receive(:all).and_return [@source_instance]

      @template = @cli.ask_user_for_template
    end

    it 'should show user templates, and prompt for selection' do
      expect(CliMiami::S).to have_received(:ay).twice.ordered
      expect(CliMiami::A).to have_received(:sk).ordered
      expect(@call_order).to eq [
        'Source Name',
        'Template Name'
      ]
    end

    it 'should return a Turple Template' do
      expect(@template).to eq @template_instance
    end
  end

  describe '#ask_user_for_project' do
    before do
      @project_path = Pathname.new './project/path'
      allow(@ask_instance).to receive(:value).and_return '', 'Project Name', '', './project/path'
      allow(@template_instance).to receive(:required_data).and_return({ required: true })
      allow(@cli).to receive(:ask_user_for_data).and_return({ data: true })
      allow(FileUtils).to receive(:mkdir_p)
      allow(Turple::Core).to receive(:load_turplefile)
      allow(Turple::Core).to receive(:settings).and_return({ project: { data: { existing: true }}})
      allow(Turple::Project).to receive(:new).and_return @project_instance

      @project = @cli.ask_user_for_project @template_instance
    end

    it 'shoud prompt for project meta data' do
      expect(CliMiami::A).to have_received(:sk).exactly(4).times.ordered
      expect(FileUtils).to have_received(:mkdir_p).ordered
      expect(Turple::Core).to have_received(:load_turplefile).ordered
      expect(@cli).to have_received(:ask_user_for_data).with({ required: true }, { existing: true }).ordered
      expect(Turple::Project).to have_received(:new).with({
        name: 'Project Name',
        path: @project_path,
        data: { data: true },
        template: @template_instance
      }).ordered
    end

    it 'should return a Turple Project' do
      expect(@project).to eq @project_instance
    end
  end

  describe '#ask_user_for_data' do
    before do
      @required_data = {
        var: 'What is var?',
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
        nested: {
          var: 'NESTED VAR',
        }
      }

      allow(@cli).to receive(:ask_user_for_data).and_call_original
      allow(@cli).to receive(:ask_user_for_data_value).and_return 'VAR', 'NESTED VAR'

      @data = @cli.ask_user_for_data @required_data, @existing_data
    end

    it 'should prompt user for missing data' do
      expect(@cli).to have_received(:ask_user_for_data).exactly(2).times
      expect(@cli).to have_received(:ask_user_for_data_value).exactly(2).times
    end

    it 'should return a hash' do
      expect(@data).to eq @completed_data
    end
  end

  describe '#ask_user_for_data_value' do
    before do
      allow(@ask_instance).to receive(:value).and_return '', 'John'

      @value = @cli.ask_user_for_data_value 'Name'
    end

    it 'should prompt user until they enter a value' do
      expect(CliMiami::A).to have_received(:sk).with('Name').twice
    end

    it 'should return the users value' do
      expect(@value).to eq 'John'
    end
  end
end
