require 'recursive-open-struct'

describe Turple do
  describe '#initialize' do
    before do
      @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template')

      allow(Turple).to receive(:load_turplefile)
      allow(Turple::Source).to receive(:new)
      allow(Turple::Template).to receive(:new).and_return RecursiveOpenStruct.new({ :required_data => 'template_data' })
      allow(Turple::Data).to receive(:new).and_return 'data'
      allow(Turple::Interpolate).to receive(:new)

      Turple.turpleobject = {
        :destination => 'foo/destination',
        :sources => {
          :foo_source => 'foo/source/path'
        }
      }

      @turple = Turple.new @template_path
    end

    after do
      allow(Turple).to receive(:load_turplefile).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
      allow(Turple::Template).to receive(:new).and_call_original
      allow(Turple::Data).to receive(:new).and_call_original
      allow(Turple::Interpolate).to receive(:new).and_call_original
    end

    it 'should load the Turplefiles' do
      expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('~'), 'Turplefile')).ordered
      expect(Turple).to have_received(:load_turplefile).with(File.join(@template_path, 'Turplefile')).ordered
      expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('foo/destination'), 'Turplefile')).ordered
    end

    it 'should initialize all components' do
      expect(Turple::Interpolate).to have_received(:new).with instance_of(RecursiveOpenStruct), 'data', 'foo/destination'
    end

    it 'should create sources from Turplefile' do
      expect(Turple::Source).to receive(:new).with :foo_source, 'foo/source/path'
      turple = Turple.new 'foo/template/path'
    end
  end

  describe '.load_turplefile' do
    before do
      allow(Turple).to receive(:turpleobject=)
    end

    before do
      allow(Turple).to receive(:turpleobject=).and_call_original
    end

    it 'should read Turplefile into turpleobject' do
      expect(Turple).to receive(:turpleobject=).with hash_including({
        'name' => 'Default Turple Configuration'
      })

      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'template', 'Turplefile')
    end
  end

  describe '.turpleobject=' do
    it 'should symbolize keys' do
      Turple.turpleobject = {
        'configuration' => {
          'foo' => {
            'bar' => 'baz'
          }
        }
      }

      expect(Turple.configuration[:foo][:bar]).to eq 'baz'
    end
  end
end
