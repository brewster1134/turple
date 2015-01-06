describe Turple::Cli do
  describe '#ate' do
    before do
      Turple.class_var :turpleobject, DEFAULT_TURPLEOBJECT

      allow(Turple).to receive(:ate)
      allow(Turple).to receive(:turpleobject=)
    end

    after do
      allow(Turple).to receive(:ate).and_call_original
      allow(Turple).to receive(:turpleobject=).and_call_original
    end

    it 'should set configuration cli flag' do
      expect(Turple).to receive(:turpleobject=) do |object|
        expect(object[:configuration][:cli]).to eq true
      end
      Turple::Cli.start ['ate']
    end

    it 'should initialize turple' do
      expect(Turple).to receive(:ate).with String
      Turple::Cli.start ['ate']
    end

    context 'when --template is not passed' do
      it 'should initialize with a blank template' do
        expect(Turple).to receive(:turpleobject=).with hash_including({ :template => '' })
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
      it 'should initialize with a destination from pwd' do
        expect(Turple).to receive(:turpleobject=) do |object|
          expect(object[:configuration][:destination]).to eq File.join(Dir.pwd, 'turple')
        end
        Turple::Cli.start ['ate']
      end
    end

    context 'when --destination is passed' do
      it 'should initialize with passed value' do
        expect(Turple).to receive(:turpleobject=) do |object|
          expect(object[:configuration][:destination]).to eq 'user/destination'
        end
        Turple::Cli.start ['ate', '--destination', 'user/destination']
      end
    end
  end
end
