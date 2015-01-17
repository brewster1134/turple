describe Turple::Template do
  context 'when a valid template path is passed' do
    before do
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
    end

    it 'should collect required data' do
      expect(@template.required_data).to eq({
        :sub => {
          :dir => true,
          :file => true
        },
        :file_content => true
      })
    end
  end

  context 'when a source is passed' do
    before do
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_return true
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_return({ :foo => 'bar' })
      allow(Turple::Source).to receive(:find_template_path)
      allow(Turple::Source).to receive(:new).and_return(OpenStruct.new({
        :template_paths => {
          'baz' => '/tmp/path/to/foo/bar'
        }
      }))
      # allow(Turple::Source).to receive(:find_template_path)

      @template = Turple::Template.new 'foo/bar##baz'
    end

    after do
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
      allow(Turple::Source).to receive(:find_template_path).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
    end

    it 'should create a new source' do
      expect(Turple::Source).to have_received(:new).with 'baz', 'foo/bar'
    end

    it 'should not search sources for template' do
      expect(Turple::Source).to_not have_received(:find_template_path)
    end
  end

  describe '.valid_configuration?' do
    before do
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
    end

    it 'should raise an error for invalid file_ext' do
      expect{@template.valid_configuration?({
        :file_ext => 'tur.ple'
      })}.to raise_error
    end

    it 'should raise an error for invalid path_separator' do
      expect{@template.valid_configuration?({
        :path_separator => :foo
      })}.to raise_error
    end

    it 'should raise an error for invalid content_separator' do
      expect{@template.valid_configuration?({
        :content_separator => :foo
      })}.to raise_error
    end

    it 'should raise an error for invalid path_regex' do
      expect{@template.valid_configuration?({
        :path_separator => '.',
        :path_regex => '\[([A-Z_]+)\]'
      })}.to raise_error
    end

    it 'should raise an error for invalid content_regex' do
      expect{@template.valid_configuration?({
        :content_separator => '.',
        :content_regex => '<>([a-z_]+)<>'
      })}.to raise_error
    end
  end
end
