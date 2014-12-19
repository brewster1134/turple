describe Turple::Template do
  describe '#initialize' do
    before do
      allow(Turple).to receive(:load_turplefile)
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_return true
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?).and_return true
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data)

      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]')
    end

    after do
      allow(Turple).to receive(:load_turplefile).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
    end

    it 'should load turplefile at template root' do
      expect(Turple).to have_received(:load_turplefile).with File.join(@template.path, 'Turplefile')
    end
  end

  describe '#scan_for_data' do
    before do
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]')
    end

    it 'should collect required data' do
      expect(@template.required_data).to eq({
        :root => {
          :dir => true,
          :file_content => true
        },
        :sub => {
          :dir => true,
          :file => true,
          :file_content => true
        },
        :file_content => true
      })
    end
  end
end
