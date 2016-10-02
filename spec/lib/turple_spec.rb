describe Turple do
  describe '#ate' do
    before do
      allow(Turple::Core).to receive(:new)

      @configuration = :configuration
      Turple.ate @configuration
    end

    after do
      allow(Turple::Core).to receive(:new).and_call_original
    end

    it 'should instantiate Turple::Core' do
      expect(Turple::Core).to have_received(:new).with @configuration
    end
  end
end
