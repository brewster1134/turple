require 'active_support/core_ext/hash/keys'
require 'date'
require 'recursive-open-struct'

describe Turple::Interpolate do
  before do
    class InterpolateTemplate
      def self.path
        File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]')
      end
      def self.configuration; DEFAULT_CONFIGURATION; end
    end

    class InterpolateData
      def self.data
        RecursiveOpenStruct.new({
          :root => {
            :dir => 'rootdir',
            :file_content => 'rootfilecontent'
          },
          :sub => {
            :dir => 'subdir',
            :file => 'subfile',
            :empty => 'subempty',
            :file_content => 'subfilecontent'
          },
          :file_content => 'filecontent'
        })
      end
    end

    Turple.load_turplefile File.join(InterpolateTemplate.path, 'Turplefile')
    Turple.turpleobject = ({
      :configuration => InterpolateTemplate.configuration,
      :data => InterpolateData.data.to_hash
    })

    @interpolate = Turple::Interpolate.new InterpolateTemplate, InterpolateData, Dir.mktmpdir
  end

  it 'should copy interpolated template to destination' do
    # verify directories
    expect(File.directory?(File.join(@interpolate.destination, 'template_rootdir'))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'template_rootdir', 'subdir'))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'template_rootdir', 'subdir_subdir'))).to eq true
    expect(File.directory?(File.join(@interpolate.destination, 'template_rootdir', 'subempty_subempty'))).to eq true

    # verify files
    expect(File.file?(File.join(@interpolate.destination, 'template_rootdir', 'subdir', 'file1.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'template_rootdir', 'subdir_subdir', 'file1_subfile.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'template_rootdir', 'subdir_subdir', 'file2_subfile.txt'))).to eq true
    expect(File.file?(File.join(@interpolate.destination, 'template_rootdir', 'Turplefile'))).to eq true

    # verify no extras
    escaped_path = File.join(@interpolate.destination, 'template_rootdir').gsub(/([\[\]\{\}\*\?\\])/, '\\\\\1')
    expect(Dir[File.join(escaped_path, '**/*')].count).to eq 7
  end

  it 'should interpolate file contents' do
    expect(File.read(File.join(@interpolate.destination, 'template_rootdir', 'subdir_subdir', 'file1_subfile.txt'))).to eq <<-EOS
root rootfilecontent file content
sub subfilecontent file content
file filecontent content
EOS
    expect(File.read(File.join(@interpolate.destination, 'template_rootdir', 'subdir_subdir', 'file2_subfile.txt'))).to eq <<-EOS
root rootfilecontent file content
sub subfilecontent file content
file filecontent content
EOS
  end

  it 'should save a complete Turplefile' do
    new_turplefile = YAML.load(File.read(File.join(@interpolate.destination, 'template_rootdir', 'Turplefile'))).deep_symbolize_keys

    expect(new_turplefile[:template]).to eq InterpolateTemplate.path
    expect(new_turplefile[:configuration]).to eq InterpolateTemplate.configuration
    expect(new_turplefile[:data]).to eq InterpolateData.data.to_hash
    expect(new_turplefile[:data_map]).to eq Turple.data_map
    expect(new_turplefile[:created_on]).to be_a String
  end
end
