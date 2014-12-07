describe Turple do
  describe '.load_turplefile' do
    it 'should handle yaml format' do
      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'Turplefile.yaml')

      expect(Turple.turplefile[:data][:foo][:bar]).to eq 'yaml'
      expect(Turple.turplefile[:template]).to eq File.join(ROOT_DIR, 'spec', 'fixtures', 'yaml_//FOO/BAR//')
    end

    it 'should handle json format' do
      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'Turplefile.json')

      expect(Turple.turplefile[:data][:foo][:bar]).to eq 'json'
      expect(Turple.turplefile[:template]).to eq File.join(ROOT_DIR, 'spec', 'fixtures', 'json_""FOO"BAR""')
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
