describe Turple do
  describe '#initialize' do
    before do
      allow(Turple::Interpolate).to receive(:new).and_call_original

      template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
      # Turple.load_turplefile File.join(template_path, 'Turplefile')
      configuration_hash = DEFAULT_CONFIGURATION.deep_merge({
        :destination => File.join(Dir.mktmpdir, 'project')
      })
      data_hash = {
        sub: {
          :dir => 'subdir',
          :file => 'subfile',
          :empty => 'subempty'
        },
        :file_content => 'filecontent'
      }

      @turple = Turple.new template_path, data_hash, configuration_hash
    end

    it 'should initialize all components' do
      expect(Turple::Interpolate).to have_received(:new).with instance_of(Turple::Template), instance_of(Turple::Data), instance_of(String)
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
