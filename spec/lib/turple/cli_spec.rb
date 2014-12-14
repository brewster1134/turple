require 'active_support/core_ext/kernel/reporting'

describe Turple::Cli do
  describe '#ate' do
    before do
      allow(Turple).to receive(:ate)
      allow(Turple).to receive(:turpleobject=)
      allow(Turple).to receive(:load_turplefile)
    end

    after do
      allow(Turple).to receive(:ate).and_call_original
      allow(Turple).to receive(:turpleobject=).and_call_original
      allow(Turple).to receive(:load_turplefile).and_call_original
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

    context 'when --turplefile is not passed' do
      it 'should load Turplefile from current directory' do
        expect(Turple).to receive(:load_turplefile).with File.join(Dir.pwd, 'Turplefile')
        Turple::Cli.start ['ate']
      end
    end

    context 'when --turplefile is passed' do
      it 'should load passed file' do
        expect(Turple).to receive(:load_turplefile).with 'user/turplefile'
        Turple::Cli.start ['ate', '--turplefile', 'user/turplefile']
      end
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
