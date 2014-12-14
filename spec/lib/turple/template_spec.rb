describe Turple::Template do
  describe '.scan_for_data' do
    before do
      @template = File.join(ROOT_DIR, 'spec', 'fixtures', 'required_data[ROOT.DIR]')
    end

    it 'should collect required data' do
      expect(Turple::Template.scan_for_data(@template)).to eq({
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

  describe.skip '#prompt_for_template' do
    before do
      allow(Readline).to receive(:readline).and_return 'foo', ROOT_DIR
      @cli = Turple::Cli.new

      quietly do
        @template = @cli.send(:prompt_for_template)
      end
    end

    after do
      allow(Readline).to receive(:readline).and_call_original
    end

    it 'should prompt user until template is valid' do
      expect(Readline).to have_received(:readline).twice
    end

    it 'should return user input template' do
      expect(@template).to eq ROOT_DIR
    end
  end

  describe '#prompt_for_data' do

  end
end
