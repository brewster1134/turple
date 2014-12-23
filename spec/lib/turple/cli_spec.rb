describe Turple::Cli do
  describe '#ate' do
    before do
      allow(Turple).to receive(:ate)
      allow(Turple).to receive(:turpleobject=)
      allow(Turple).to receive(:method_missing)
      allow(Turple).to receive(:load_turplefile)
    end

    after do
      allow(Turple).to receive(:ate).and_call_original
      allow(Turple).to receive(:turpleobject=).and_call_original
      allow(Turple).to receive(:method_missing).and_call_original
      allow(Turple).to receive(:load_turplefile).and_call_original
    end

    it 'should load the destination Turplefile' do
      expect(Turple).to receive(:load_turplefile).with File.join(Dir.pwd, 'turple', 'Turplefile')
      Turple::Cli.start ['ate']
    end

    it 'should set configuration cli flag' do
      expect(Turple).to receive(:turpleobject=) do |object|
        object[:configuration][:cli] == true
      end
      Turple::Cli.start ['ate']
    end

    it 'should initialize turple' do
      expect(Turple).to receive(:ate).with anything, anything, anything
      Turple::Cli.start ['ate']
    end

    context 'when --template is not passed' do
      it 'should initialize with a nil template' do
        expect(Turple).to receive(:turpleobject=).with hash_including({ :template => nil })
        Turple::Cli.start ['ate']
      end
    end

    context 'when --template is passed' do
      it 'should initialize with passed value' do
        expect(Turple).to receive(:turpleobject=).with hash_including({ :template => 'user/template' })
        Turple::Cli.start ['ate', '--template', 'user/template']
      end
    end

    context 'when --destination is not passed' do
      it 'should initialize with current directory' do
        expect(Turple).to receive(:turpleobject=) do |object|
          object[:configuration][:destination] == Dir.pwd
        end
        Turple::Cli.start ['ate']
      end
    end

    context 'when --destination is passed' do
      it 'should initialize with passed value' do
        expect(Turple).to receive(:turpleobject=) do |object|
          object[:configuration][:destination] == 'user/destination'
        end
        Turple::Cli.start ['ate', '--destination', 'user/destination']
      end
    end
  end
end
