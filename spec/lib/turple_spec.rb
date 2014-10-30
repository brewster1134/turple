require 'tmpdir'

describe Turple do
  before do
    tmp_dir = Dir.mktmpdir
    FileUtils.cp_r File.join('spec', 'fixtures'), tmp_dir
    @turple = Turple.ate 'test <>foo.bar<> string', { foo: { :bar => :baz }}
  end

  it 'should create dot notation accessible options' do
    expect(@turple.instance_var(:data).foo.bar).to eq :baz
  end

  context 'with directory' do
    before do
      tmp_dir = Dir.mktmpdir
      FileUtils.cp_r File.join('spec', 'fixtures'), tmp_dir
      @turple = Turple.new tmp_dir, { foo: { :bar => :baz }}
    end

    it 'should process and rename files' do
      expect(File.read(File.join(@turple.output, 'fixtures', 'dir_one_baz', 'dir_two_baz', 'file_baz.txt'))).to include 'text baz file'
    end
  end

  context 'with file' do
    before do
      tmp_dir = Dir.mktmpdir
      FileUtils.cp_r File.join('spec', 'fixtures', 'dir_one_[FOO.BAR]', 'dir_two_[FOO.BAR]', 'file_[FOO.BAR].txt.turple'), tmp_dir
      @turple = Turple.new tmp_dir, { foo: { :bar => :baz }}
    end

    it 'should process and rename files' do
      expect(File.read(File.join(@turple.output, 'file_baz.txt'))).to include 'text baz file'
    end
  end

  context 'with string' do
    before do
      tmp_dir = Dir.mktmpdir
      FileUtils.cp_r File.join('spec', 'fixtures', 'dir_one_[FOO.BAR]', 'dir_two_[FOO.BAR]', 'file_[FOO.BAR].txt.turple'), tmp_dir
      @turple = Turple.new 'test <>foo.bar<> string', { foo: { :bar => :baz }}
    end

    it 'should process and rename files' do
      expect(@turple.output).to eq 'test baz string'
    end
  end
end
