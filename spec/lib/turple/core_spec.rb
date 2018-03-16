describe Turple::Core do
  before do
    @core = allocate :core
    @error = allocate :error
    @source = allocate :source
    @template = allocate :template
  end

  after do
    allow(File).to receive(:read).and_call_original
    allow(Turple::Project).to receive(:new).and_call_original
    allow(Turple::Source).to receive(:find).and_call_original
    allow(Turple::Source).to receive(:new).and_call_original
    allow(Turple::Template).to receive(:find).and_call_original
    allow(Turple::Template).to receive(:new).and_call_original
  end

  describe '#initialize' do
    before do
      allow(Turple::Project).to receive(:new)
      allow(Turple::Source).to receive(:find)
      allow(Turple::Source).to receive(:new)
      allow(Turple::Template).to receive(:find)
      allow(Turple::Template).to receive(:new)
    end

    context 'when source is passed' do
      context 'when source exists' do
        it 'should find the existing source' do
          allow(Turple::Source).to receive(:find).and_return @source

          expect(Turple::Source).to receive(:find).with('user_source_existing')
          expect(Turple::Source).to_not receive(:new)

          @core.send :initialize, source: 'user_source_existing'
        end
      end

      context 'when source does not exist' do
        it 'should initialize a new source' do
          allow(Turple::Source).to receive(:find).and_return nil

          expect(Turple::Source).to receive(:find).with('user_source_new').ordered
          expect(Turple::Source).to receive(:new).with('user_source_new').ordered

          @core.send :initialize, source: 'user_source_new'
        end
      end
    end

    context 'when template is passed as a string' do
      context 'when a source is passed' do
        before do
          allow(Turple::Source).to receive(:find).and_return @source
        end

        it 'should return the template in the source' do
          allow(@source).to receive(:find_template).and_return @template

          expect(@source).to receive(:find_template).with('user_template')
          expect(Turple::Template).to_not receive(:find)
          expect(Turple::Template).to_not receive(:new)

          @core.send :initialize, template: 'user_template', source: 'user_source'
        end
      end

      context 'when a source is not passed' do
        context 'when the template exists' do
          it 'should find the existing template' do
            allow(Turple::Template).to receive(:find).and_return true

            expect(Turple::Template).to receive(:find).with 'user_template'
            expect(Turple::Template).to_not receive(:new)

            @core.send :initialize, template: 'user_template'
          end
        end

        context 'when the template does not exist' do
          it 'should initialize a new template' do
            allow(Turple::Template).to receive(:find).and_return nil
            allow(Turple::Template).to receive(:new)

            expect(Turple::Template).to receive(:find).with('user_template').ordered
            expect(Turple::Template).to receive(:new).with('user_template').ordered

            @core.send :initialize, template: 'user_template'
          end
        end
      end
    end

    context 'when project is passed as a hash' do
      it 'should initialize a new project' do
        allow(Turple::Project).to receive(:new)

        expect(Turple::Project).to receive(:new).with({
          name: :name,
          path: :path,
          data: :data,
          template: @template
        })

        @core.send :initialize, template: @template, project: { name: :name, path: :path, data: :data }
      end
    end

    context 'when project is passed as a string' do
      it 'should expect it to be a path to an existing project directory' do
        allow(Turple::Core).to receive(:settings).and_return({
          project: {
            name: 'Project Name',
            path: './project_string',
            data: {
              foo: 'foo'
            }
          }
        })

        expect(Turple::Core).to receive(:load_turplefile).with('./project_string')
        expect(Turple::Project).to receive(:new).with({
          name: 'Project Name',
          path: File.expand_path('./project_string'),
          data: { foo: 'foo' },
          template: @template
        })

        @core.send :initialize, template: @template, project: './project_string'
      end
    end
  end

  describe '.load_turplefile' do
    before do
      allow(File).to receive(:read)
      allow(Turple::Core).to receive(:settings=)
      allow(YAML).to receive(:load).and_return({
        'project' => :project,
        'sources' => [
          'foo_source',
          'bar_source'
        ]
      })

      @source_new_calls = []
      allow(Turple::Source).to receive(:new) do |location|
        @source_new_calls << location
      end

      @turplefile = Turple::Core.load_turplefile '~'
    end

    it 'should read the absolute path' do
      turplefile_path = File.join(ENV['HOME'], 'Turplefile')

      expect(File).to have_received(:read).with(turplefile_path)
    end

    it 'should initialize each source and remove them from the settings' do
      expect(@source_new_calls).to eq ['foo_source', 'bar_source']
      expect(Turple::Source).to have_received(:new).exactly(2).times.ordered
      expect(Turple::Core).to have_received(:settings=).with({ project: :project, sources: ['foo_source', 'bar_source'] }).ordered
      
      expect(@turplefile).to eq({
        project: :project,
        sources: [
          'foo_source',
          'bar_source'
        ]        
      })
    end
  end

  describe '.settings=' do
    before do
      Turple::Core.class_variable_set :@@settings, {}

      Turple::Core.settings=({
        'foo' => 'foo',
        'project' => {
          'fname' => 'John'
        }
      })

      Turple::Core.settings=({
        'bar' => 'bar',
        'project' => {
          'fname' => 'Jane',
          'lname' => 'Doe'
        }
      })
    end

    it 'should merge into the global settings' do
      expect(Turple::Core.settings).to eq({
        foo: 'foo',
        bar: 'bar',
        project: {
          fname: 'Jane',
          lname: 'Doe'
        }
      })
    end
  end
end
