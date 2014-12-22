describe Turple::Template do
  before do
    allow(Turple).to receive(:load_turplefile)
  end

  after do
    allow(Turple).to receive(:load_turplefile).and_call_original
  end

  context 'with a valid configuration' do
    before do
      @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template'), DEFAULT_CONFIGURATION
    end

    it 'should load turplefile at template root' do
      expect(Turple).to have_received(:load_turplefile).with File.join(@template.path, 'Turplefile')
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
