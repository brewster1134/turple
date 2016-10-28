describe Turple::Source do
  describe '#initialize' do
    before do
      allow(Dir).to receive(:mktmpdir)
      allow(Sourcerer).to receive(:new)

      @source_instance = Turple::Source.allocate
      @source_instance.send :initialize, 'source_location'
    end

    after do
      allow(Dir).to receive(:mktmpdir).and_call_original
      allow(Sourcerer).to receive(:new).and_call_original
    end

    it 'should download the source to a tmp dir' do
      allow(Dir).to receive(:mktmpdir).and_return '/tmp/source'

      expect(Dir).to receive(:mktmpdir).with('source_location').ordered
      expect(Sourcerer).to receive(:new).with('/tmp/source').ordered
      expect(Turple::Core).to receive(:load_turplefile).with('/tmp/source').ordered
    end

    it 'should load the source Turplefile' do
      skip
    end

    it 'should initialize all templates' do
      expect(Turple::Template).to receive(:new).exactly(2).times
      skip
    end
  end
end

# describe Turple::Source do
#   before do
#     @source_path = File.join(ROOT_DIR, 'spec', 'fixtures')
#     @foo_source = Turple::Source.new :foo_source, @source_path
#     @bar_source = Turple::Source.new :bar_source, @source_path
#   end
#
#   it 'should add template paths' do
#     expect(@foo_source.instance_var(:template_paths)['template']).to end_with 'template'
#     expect(@bar_source.instance_var(:template_paths)['template']).to end_with 'template'
#   end
#
#   it 'should add to global sources' do
#     expect(Turple::Source.class_var(:sources)[:foo_source]).to eq @foo_source
#     expect(Turple::Source.class_var(:sources)[:bar_source]).to eq @bar_source
#   end
#
#   describe '.find_template_path' do
#     before do
#       @foo_source.instance_var :template_paths, { :foo_template => '/foo/source/foo/template' }
#       @bar_source.instance_var :template_paths, { :foo_template => '/bar/source/foo/template' }
#     end
#
#     context 'when no source is specified' do
#       it 'should find the first matching template from the sources' do
#         expect(Turple::Source.find_template_path(:foo_template)).to eq '/foo/source/foo/template'
#       end
#     end
#
#     context 'when a source is specified' do
#       it 'should use a template from the source' do
#         expect(Turple::Source.find_template_path(:foo_template, :bar_source)).to eq '/bar/source/foo/template'
#       end
#     end
#   end
# end
