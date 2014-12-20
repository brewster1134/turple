describe Turple::Template do
  before do
    allow(Turple).to receive(:load_turplefile)
    @template = Turple::Template.new File.join(ROOT_DIR, 'spec', 'fixtures', 'template_[ROOT.DIR]'), DEFAULT_CONFIGURATION
  end

  after do
    allow(Turple).to receive(:load_turplefile).and_call_original
  end

  it 'should load turplefile at template root' do
    expect(Turple).to have_received(:load_turplefile).with File.join(@template.path, 'Turplefile')
  end

  it 'should collect required data' do
    expect(@template.required_data).to eq({
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
