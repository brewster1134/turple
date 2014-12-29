require 'recursive-open-struct'

describe Turple::Template do
  before do
    allow(Turple).to receive(:load_turplefile)
  end

  after do
    allow(Turple).to receive(:load_turplefile).and_call_original
  end

  context 'when a source is detected' do
    before do
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_return true
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data)
      allow(Sourcerer).to receive(:new).and_return RecursiveOpenStruct.new({ :destination => '/path/to/source' })

      @template = Turple::Template.new 'url|template', DEFAULT_CONFIGURATION
    end

    after do
      allow_any_instance_of(Turple::Template).to receive(:valid_path?).and_call_original
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
      allow(Sourcerer).to receive(:new).and_call_original
    end

    it 'should download source' do
      expect(Sourcerer).to have_received(:new).with 'url'
    end

    it 'should set path to source path' do
      expect(@template.path).to eq '/path/to/source/template'
    end
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
