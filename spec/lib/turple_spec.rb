describe Turple do
  before do
    root_dir = Dir.pwd

    @destination_dir = Dir.mktmpdir
    @template_dir = File.join(root_dir, 'spec', 'fixtures', 'dir_one_[FOO.BAR]')
    @template_file = File.join(@template_dir, 'dir_two_[FOO.BAR]', 'file_[FOO.BAR].txt.turple')
  end

  context.skip 'from command line' do
    context 'with directory' do
      it 'should process and rename files' do
        Turple.new @template_dir, @tmp_dir, { foo: { :bar => :baz }}

        expect(File.read(File.join(Dir.pwd, 'dir_one_baz', 'dir_two_baz', 'file_baz.txt'))).to include 'text baz file'
      end
    end

    context 'with file' do
      it 'should process and rename files' do
        Turple.new File.join(@template_dir, 'dir_one_[FOO.BAR]', 'dir_two_[FOO.BAR]', 'file_[FOO.BAR].txt.turple'), @tmp_dir, { foo: { :bar => :baz }}

        expect(File.read(File.join(Dir.pwd, 'file_baz.txt'))).to include 'text baz file'
      end
    end

    context 'with string' do
      context 'with a destination' do
        it 'should process and save to a file' do
          Turple.new 'text <>foo.bar<> string file', File.join(@tmp_dir, 'output.txt'), { foo: { :bar => :baz }}

          expect(File.read(File.join(Dir.pwd, 'output.txt'))).to include 'text baz string file'
        end
      end

      context 'without a destination' do
        it 'should process and provide output' do
          turple = Turple.new 'text <>foo.bar<> string', nil, { foo: { :bar => :baz }}

          expect(turple.output).to eq 'text baz string'
        end
      end
    end
  end

  context 'with ruby' do
    it 'should create dot notation accessible options' do
      turple = Turple.ate 'test <>foo.bar<> string', nil, { foo: { :bar => :baz }}

      expect(turple.data.foo.bar).to eq :baz
    end

    context 'with directory' do
      it 'should process and rename files' do
        turple = Turple.new @template_dir, @destination_dir, { foo: { :bar => :baz }}

        expect(File.read(File.join(turple.destination, 'dir_one_baz', 'dir_two_baz', 'file_baz.txt'))).to include 'text baz file'
      end
    end

    context 'with file' do
      it 'should process and rename files' do
        turple = Turple.new @template_file, @destination_dir, { foo: { :bar => :baz }}

        expect(File.read(File.join(turple.destination, 'file_baz.txt'))).to include 'text baz file'
      end
    end

    context 'with string' do
      context 'with a destination' do
        it 'should process and save to a file' do
          turple = Turple.new 'text <>foo.bar<> string file', File.join(@destination_dir, 'output.txt'), { foo: { :bar => :baz }}

          expect(File.read(turple.destination)).to include 'text baz string file'
        end
      end

      context 'without a destination' do
        it 'should process and provide output' do
          turple = Turple.new 'text <>foo.bar<> string', nil, { foo: { :bar => :baz }}

          expect(turple.output).to eq 'text baz string'
        end
      end
    end
  end
end
