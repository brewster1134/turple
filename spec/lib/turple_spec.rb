describe Turple do
  describe '#ate' do
    before do
      allow(Turple::Core).to receive(:load_turplefile)
      allow(Turple::Core).to receive(:new)

      Turple.ate foo: 'foo'
    end

    after do
      allow(Turple::Core).to receive(:load_turplefile).and_call_original
      allow(Turple::Core).to receive(:new).and_call_original
    end

    it 'should start Turple' do
      expect(Turple::Core).to have_received(:load_turplefile).with(ENV['HOME']).ordered
      expect(Turple::Core).to have_received(:new).with({ foo: 'foo' }).ordered
    end
  end
end
