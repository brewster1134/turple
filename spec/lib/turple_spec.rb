describe Turple do
  describe '.load_turplefile' do
    before do
      allow(Turple).to receive(:turpleobject=)
    end

    before do
      allow(Turple).to receive(:turpleobject=).and_call_original
    end

    it 'should handle yaml format' do
      expect(Turple).to receive(:turpleobject=).with hash_including({ 'template' => 'yaml_//FOO/BAR//' })
      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'Turplefile.yaml')
    end

    it 'should handle json format' do
      expect(Turple).to receive(:turpleobject=).with hash_including({ 'template' => 'json_""FOO"BAR""' })
      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'Turplefile.json')
    end
  end

  describe '.turpleobject=' do
    it 'should merge hash into turpleobject with symbolized keys' do
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

#   before do
#     @destination_dir = Dir.mktmpdir
#     @template_dir = File.join(ROOT_DIR, 'spec', 'fixtures', 'dir_one_[FOO.BAR]')
#     @template_file = File.join(@template_dir, 'dir_two_[FOO.BAR]', 'file_[FOO.BAR].txt.turple')
#   end

#   it 'should create dot notation accessible options' do
#     turple = Turple.ate 'test <>foo.bar<> string', nil, { foo: { :bar => :baz }}

#     expect(turple.data.foo.bar).to eq :baz
#   end

#   it 'should process directories recursively' do
#     turple = Turple.new @template_dir, @destination_dir, { foo: { :bar => :baz }}

#     expect(File.read(File.join(turple.destination, 'dir_one_baz', 'dir_two_baz', 'file_baz.txt'))).to include 'text baz file'
#   end

#   it 'should process single files' do
#     turple = Turple.new @template_file, @destination_dir, { foo: { :bar => :baz }}

#     expect(File.read(File.join(turple.destination, 'file_baz.txt'))).to include 'text baz file'
#   end

#   context 'when processing a string' do
#     context 'with a destination' do
#       it 'should save to a file' do
#         turple = Turple.new 'text <>foo.bar<> string file', File.join(@destination_dir, 'output.txt'), { foo: { :bar => :baz }}

#         expect(File.read(turple.destination)).to include 'text baz string file'
#       end
#     end

#     context 'without a destination' do
#       it 'should provide output' do
#         turple = Turple.new 'text <>foo.bar<> string', nil, { foo: { :bar => :baz }}

#         expect(turple.output).to eq 'text baz string'
#       end
#     end
#   end
end
