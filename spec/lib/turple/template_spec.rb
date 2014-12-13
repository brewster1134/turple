describe Turple::Template do
  before do
    @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'required_data[ROOT.DIR]')
  end

  it 'should collect required data' do
    expect(@template.send(:scan_for_data)).to eq({
      :root => {
        :dir => true,
        :file_content => true
      },
      :sub => {
        :dir => true,
        :file => true,
        :file_content => true
      },
      :file_content => true
    })
  end
end
