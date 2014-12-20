describe Turple do
  describe.skip '#initialize' do
    before do
      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]', 'Turplefile')
      template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]', 'Turplefile')
      configuration_hash = DEFAULT_CONFIGURATION
      data_hash = {
        :data_map => {
          :root => {
            :dir => 'rootdir',
            :file_content => 'rootfilecontent'
          },
          sub: {
            :dir => 'subdir',
            :file => 'subfile',
            :empty => 'subempty',
            :file_content => 'subfilecontent'
          },
          :file_content => 'filecontent'
        }
      }

      @turple = Turple.new template_path, data_hash, configuration_hash
    end

    it 'should initialize all components' do
      expect(@turple.instance_var(:template)).to be_a Turple::Template
      expect(@turple.instance_var(:data)).to be_a Turple::Data
      expect(@turple.instance_var(:interpolate)).to be_a Turple::Interpolate
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

      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]', 'Turplefile')
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
