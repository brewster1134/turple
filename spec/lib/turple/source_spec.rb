describe Turple::Source do
  describe '#initialize' do
    before do
      @source = allocate :source
      @sourcerer = Sourcerer::Core.allocate

      allow(Sourcerer).to receive(:new).and_return @sourcerer
      allow(Turple::Core).to receive(:load_turplefile)
      allow(@source).to receive(:add_templates)
      allow(@sourcerer).to receive(:path)
      allow(@sourcerer).to receive(:files).and_return [
        'tempate_one',
        'tempate_two'
      ]

      @source.send :initialize, 'source_location'
    end

    after do
      allow(Sourcerer).to receive(:new).and_call_original
      allow(Turple::Core).to receive(:load_turplefile).and_call_original
    end

    it 'should initialize in the right order' do
      expect(Sourcerer).to have_received(:new).with('source_location', String).ordered
      expect(Turple::Core).to have_received(:load_turplefile).ordered
      expect(@source).to have_received(:add_templates).ordered
    end
  end
end
