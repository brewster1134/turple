describe Turple::Template do
  describe '#scan_for_data' do
    before do
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?)
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'required_data[ROOT.DIR]'), {}, {
        :file_ext => 'turple',
        :path_regex => /\[([A-Z_\.]+)\]/,
        :path_separator => '.',
        :content_regex => /<>([a-z_.]+)<>/,
        :content_separator => '.'
      }
    end

    after do
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?).and_call_original
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

  describe '#prompt_for_template' do
    before do
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data)
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?).and_return true

      @template = Turple::Template.new '', {}, {}

      allow(@template).to receive(:valid_path?).and_return false, false, true
      allow(A).to receive(:sk)

      @template.send :prompt_for_template
    end

    after do
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:valid_configuration?).and_call_original
      allow(A).to receive(:sk).and_call_original
    end

    it 'should prompt user until template is valid' do
      # check valid path 3 times
      expect(@template).to have_received(:valid_path?).exactly(3).times

      # only 2 of the 3 checks were false, so we only prompt twice
      expect(A).to have_received(:sk).exactly(2).times
    end

    it 'should return user input template' do
      expect(@template.path).to eq ROOT_DIR
    end
  end
end
