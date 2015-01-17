require 'active_support/core_ext/hash/keys'
require 'date'
require 'recursive-open-struct'

describe Turple::Interpolate do
  before do
    # create mocks for template and data instances
    @template = RecursiveOpenStruct.new({
      :configuration => DEFAULT_TURPLEOBJECT[:configuration],
      :path => File.join(ROOT_DIR, 'spec', 'fixtures', 'template'),
      :name => 'Template!'
    })

    @data = RecursiveOpenStruct.new({
      :data => {
        :sub => {
          :dir => 'subdir',
          :file => 'subfile',
          :empty => 'subempty'
        },
        :file_content => 'filecontent'
      }
    })

    # create emtpy dir since they are ignored by git
    FileUtils.mkdir_p File.join(@template.path, 'subempty_[SUB.EMPTY]')

    # load the template Turplefile
    Turple.load_turplefile File.join(@template.path, 'Turplefile')

    @destination = File.join(ROOT_DIR, 'tmp', 'project')
    @interpolate = Turple::Interpolate.new @template, @data, @destination
  end

  after do
    FileUtils.rm_rf @destination
  end

  it 'should copy interpolated template to destination' do
    # verify directories
    expect(File.directory?(File.join(@interpolate.destination))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'subdir'))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'subdir_subdir'))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'subempty_subempty'))).to eq true

    # verify files
    expect(File.file?(File.join(@interpolate.destination, 'subdir', 'file1.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'subdir_subdir', 'file1_subfile.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'subdir_subdir', 'file2_subfile.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'Turplefile'))).to eq true

    # verify no extras
    expect(Dir[File.join(@interpolate.destination, '**/*')].count).to eq 7
  end

  it 'should interpolate file contents' do
    expect(File.read(File.join(@interpolate.destination, 'subdir_subdir', 'file1_subfile.txt'))).to eq <<-EOS
file filecontent content
EOS
    expect(File.read(File.join(@interpolate.destination, 'subdir_subdir', 'file2_subfile.txt'))).to eq <<-EOS
file filecontent content
EOS
  end

  it 'should save a complete Turplefile' do
    new_turplefile = YAML.load(File.read(File.join(@interpolate.destination, 'Turplefile'))).deep_symbolize_keys

    expect(new_turplefile[:template]).to eq 'Template!'
    expect(new_turplefile[:created_on]).to be_a String
  end
end
