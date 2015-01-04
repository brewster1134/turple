describe Turple::Template do
  context 'when a source is passed' do
    before do
      allow(Turple::Source).to receive(:new)
      allow(Turple::Source).to receive(:find_template_path)

      @template = Turple::Template.new('foo/bar##baz', DEFAULT_TURPLEOBJECT[:configuration]) rescue nil
    end

    after do
      allow(Turple::Source).to receive(:new).and_call_original
      allow(Turple::Source).to receive(:find_template_path).and_call_original
    end

    it 'should create a new source' do
      expect(Turple::Source).to have_received(:new).with 'baz', 'foo/bar'
    end

    it 'should search for the template from that source' do
      expect(Turple::Source).to have_received(:find_template_path).with 'baz', 'baz'
    end
  end

  context 'with a valid configuration' do
    before do
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), DEFAULT_TURPLEOBJECT[:configuration]
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

  context 'with an invalid configuration' do
    it 'should raise an error for invalid file_ext' do
      expect{Turple::Template.new(File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), {
        :file_ext => 'tur.ple'
      })}.to raise_error
    end

    it 'should raise an error for invalid path_separator' do
      expect{Turple::Template.new(File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), {
        :path_separator => :foo
      })}.to raise_error
    end

    it 'should raise an error for invalid content_separator' do
      expect{Turple::Template.new(File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), {
        :content_separator => :foo
      })}.to raise_error
    end

    it 'should raise an error for invalid path_regex' do
      expect{Turple::Template.new(File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), {
        :path_separator => '.',
        :path_regex => '\[([A-Z_]+)\]'
      })}.to raise_error
    end

    it 'should raise an error for invalid content_regex' do
      expect{Turple::Template.new(File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), {
        :content_separator => '.',
        :content_regex => '<>([a-z_]+)<>'
      })}.to raise_error
    end
  end
end
