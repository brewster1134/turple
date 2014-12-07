describe Turple::Cli do
  describe '#ate' do
    before do
      allow(Turple).to receive(:load_turplefile).and_return({ :template => 'turplefile/template', :data => { :data => true }})
      allow(Turple).to receive(:template).and_return 'turplefile/template'
      allow(Turple).to receive(:data).and_return({ :data => true })
      allow(Turple).to receive(:configuration).and_return({ :configuration => true })
      allow(Turple).to receive(:ate).and_return true
    end

    after do
      allow(Turple).to receive(:load_turplefile).and_call_original
      allow(Turple).to receive(:template).and_call_original
      allow(Turple).to receive(:data).and_call_original
      allow(Turple).to receive(:configuration).and_call_original
      allow(Turple).to receive(:ate).and_call_original
    end

    it 'should set configuration cli flag' do
      Turple::Cli.start ['ate']
      expect(Turple.configuration[:cli]).to eq true
    end

    context 'when --turplefile is passed' do
      it 'should load passed value' do
        expect(Turple).to receive(:load_turplefile).with 'user/turplefile'
        Turple::Cli.start ['ate', '--turplefile', 'user/turplefile']
      end
    end

    context 'when --turplefile is NOT passed' do
      it 'should load Turplefile from current directory' do
        expect(Turple).to receive(:load_turplefile).with File.join(ROOT_DIR, 'Turplefile')
        Turple::Cli.start ['ate']
      end
    end

    context 'when --template is passed' do
      it 'should initialize with passed value' do
        expect(Turple).to receive(:ate).with hash_including({ :template => 'user/template' })
        Turple::Cli.start ['ate', '--template', 'user/template']
      end
    end

    context 'when --template is NOT passed' do
      it 'should initialize with value from Turplefile' do
        allow(Turple).to receive(:template).and_return 'turplefile/template'
        expect(Turple).to receive(:ate).with hash_including({ :template => 'turplefile/template' })

        Turple::Cli.start ['ate']
      end
    end

    context 'when --destination is passed' do
      it 'should initialize with passed value' do
        expect(Turple).to receive(:ate).with hash_including({ :destination => 'user/destination' })
        Turple::Cli.start ['ate', '--destination', 'user/destination']
      end
    end

    context 'when --destination is NOT passed' do
      it 'should initialize with current directory' do
        expect(Turple).to receive(:ate).with hash_including({ :destination => Dir.pwd })
        Turple::Cli.start ['ate']
      end
    end

    context 'when user is prompted' do
      before do
        allow($stdout).to receive(:write)

        allow_any_instance_of(Turple::Cli).to receive(:prompt_for_template)
        allow_any_instance_of(Turple::Cli).to receive(:prompt_for_data)
      end

      after do
        allow_any_instance_of(Turple::Cli).to receive(:prompt_for_template).and_call_original
        allow_any_instance_of(Turple::Cli).to receive(:prompt_for_data).and_call_original

        allow($stdout).to receive(:write).and_call_original
      end

      context 'when no template can be found' do
        before do
          allow(Turple).to receive(:template).and_return nil
        end

        it 'should prompt for template' do
          expect_any_instance_of(Turple::Cli).to receive(:prompt_for_template)
          Turple::Cli.start ['ate']
        end
      end

      context 'when no data can be found' do
        before do
          allow(Turple).to receive(:data).and_return nil
        end

        it 'should prompt for data' do
          expect_any_instance_of(Turple::Cli).to receive(:prompt_for_data)
          Turple::Cli.start ['ate']
        end
      end
    end
  end

  describe '#prompt_for_template' do
    before do
      allow($stdout).to receive(:write)
      allow(Readline).to receive(:readline).and_return 'foo', ROOT_DIR
      @cli = Turple::Cli.new
      @template = @cli.send(:prompt_for_template)
    end

    after do
      allow($stdout).to receive(:write).and_call_original
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
