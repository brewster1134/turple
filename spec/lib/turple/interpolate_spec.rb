require 'active_support/core_ext/hash/keys'
require 'date'
require 'recursive-open-struct'

describe Turple::Interpolate do
  before do
    class InterpolateTemplate
      def self.path
        File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
      end
      def self.configuration; DEFAULT_CONFIGURATION; end
    end

    class InterpolateData
      def self.data
        RecursiveOpenStruct.new({
          :sub => {
            :dir => 'subdir',
            :file => 'subfile',
            :empty => 'subempty'
          },
          :file_content => 'filecontent'
        })
      end
    end

    allow(Turple).to receive(:turpleobject).and_return({
      :configuration => InterpolateTemplate.configuration,
      :data => InterpolateData.data.to_hash,
      :data_map => InterpolateData.data.to_hash
    })

    # create emtpy dir since they are ignored by git
    FileUtils.mkdir_p File.join(InterpolateTemplate.path, 'subempty_[SUB.EMPTY]')

    Turple.load_turplefile File.join(InterpolateTemplate.path, 'Turplefile')

    @destination = File.expand_path(File.join('tmp', 'project'))
    @interpolate = Turple::Interpolate.new InterpolateTemplate, InterpolateData, @destination
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

    expect(new_turplefile[:template]).to eq InterpolateTemplate.path
    expect(new_turplefile[:configuration]).to eq InterpolateTemplate.configuration
    expect(new_turplefile[:data]).to eq InterpolateData.data.to_hash
    expect(new_turplefile[:data_map]).to eq Turple.data_map
    expect(new_turplefile[:created_on]).to be_a String
  end
end
