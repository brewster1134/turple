describe Turple::Project do
  before do
    @project = allocate :project
    @source = allocate :source
    @template = allocate :template
    allow(@project).to receive(:interpolate)
    allow(@project).to receive(:missing_data).and_return Hash.new
    allow(@project).to receive(:write_to_turplefile)
    allow(@source).to receive(:location).and_return 'source/location'
    allow(@template).to receive(:name).and_return 'Template Name'
    allow(@template).to receive(:required_data).and_return Hash.new
    allow(@template).to receive(:source).and_return @source
    allow(FileUtils).to receive(:mkdir_p)
  end

  after do
    allow(FileUtils).to receive(:mkdir_p).and_call_original
  end

  describe '#initialize' do
    #
    # VALIDATION
    #
    context 'when the path is missing' do
      it 'should raise an error' do
        expect{ @project.send(:initialize, data: Hash.new, template: @template) }.to raise_error Turple::Error
      end
    end

    context 'when the template is missing' do
      it 'should raise an error' do
        expect{ @project.send(:initialize, data: Hash.new, path: './path') }.to raise_error Turple::Error
      end
    end

    context 'when the data is missing' do
      it 'should raise an error' do
        expect{ @project.send(:initialize, path: './path', template: @template) }.to raise_error Turple::Error
      end
    end

    context 'when the name exists' do
      it 'should use the provided name' do
        @project.send :initialize, name: 'Project Name', path: './path', data: Hash.new, template: @template

        expect(@project.name).to eq 'Project Name'
      end
    end

    context 'when the name does not exist' do
      it 'should create a name based on the path' do
        @project.send :initialize, path: './path/to/some_kind-of Folder name', data: Hash.new, template: @template

        expect(@project.name).to eq 'Some Kind Of Folder Name'
      end
    end

    context 'when the path directory does not exist' do
      before do
        @project.send :initialize, path: './non/existing/path', data: Hash.new, template: @template
      end

      it 'should create the path' do
        expect(FileUtils).to have_received(:mkdir_p) do |pathname|
          expect(pathname.to_s).to eq File.expand_path('./non/existing/path')
        end
      end
    end

    context 'when the data is hash' do
      context 'when there is missing data' do
        before do
          allow(@project).to receive(:missing_data).and_return({ missing: 'data' })
        end

        it 'should raise an error' do
          expect{ @project.send(:initialize, data: { required: 'data' }, path: './path', template: @template) }.to raise_error Turple::Error
        end
      end

      context 'when there is no missing data' do
        before do
          allow(@project).to receive(:missing_data).and_return Hash.new
        end

        it 'should interpolate with the data' do
          allow(@template).to receive(:required_data).and_return({ required: 'data' })

          expect(@project).to receive(:missing_data).with({ required: 'data' }, { required: 'data' }).ordered
          expect(@project).to receive(:interpolate).with(@template).ordered

          @project.send :initialize, data: { required: 'data' }, path: './path', template: @template
        end
      end

    end

    context 'when all arguments are valid' do
      before do
        @project.send :initialize, name: 'Project Name', path: './path', data: { project: 'data' }, template: @template
      end

      it 'should write to the Turplefile' do
        expect(@project).to have_received(:write_to_turplefile).with({
          project: {
            name: 'Project Name',
            source: 'source/location',
            template: 'Template Name',
            data: { project: 'data' },
            created_on: instance_of(String)
          }
        })
      end

      it 'should call interpolate ' do
        expect(@project).to have_received(:interpolate).with(@template)
      end
    end
  end
end
