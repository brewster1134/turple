describe Turple::Source do
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
