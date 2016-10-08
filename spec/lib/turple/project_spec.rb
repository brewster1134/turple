describe Turple::Project do
  describe '#initialize' do
    before do
      @project_instance = Turple::Project.allocate

      allow(@project_instance).to receive(:settings)
      allow(Turple::Core).to receive(:load_turplefile)

      @project_instance.send :initialize, 'project_path'
    end

    after do
      allow(Turple::Core).to receive(:load_turplefile).and_call_original
    end

    it 'should load project Turplefile' do
      expect(Turple::Core).to have_received(:load_turplefile).with 'project_path'
    end
  end
end
