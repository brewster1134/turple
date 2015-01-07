describe Turple::Cli do
  before do
    Turple.class_var :turpleobject, DEFAULT_TURPLEOBJECT
  end

  describe '#ate' do
    before do
      allow(Turple).to receive(:ate)
    end

    after do
      allow(Turple).to receive(:ate).and_call_original
    end

    context 'with no options passed' do
      before do
        Turple::Cli.start ['ate']
      end

      it 'should initialize turple' do
        expect(Turple).to have_received(:ate).with nil, {}, {}
      end

      it 'should enable interactive mode' do
        expect(Turple.interactive).to eq true
      end
    end

    context 'with template passed' do
      before do
        Turple::Cli.start ['ate', '--template', 'user/template']
      end

      it 'should initialize with provided template' do
        expect(Turple).to have_received(:ate).with 'user/template', {}, {}
      end
    end

    context 'with destination passed' do
      before do
        Turple::Cli.start ['ate', '--destination', 'user/destination']
      end

      it 'should initialize with provided destination' do
        expect(Turple).to have_received(:ate).with anything, {}, { :destination => 'user/destination' }
      end
    end
  end
end
