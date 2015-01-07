require 'recursive-open-struct'

describe Turple do
  describe '#initialize' do
    before do
      Turple.class_var :turpleobject, DEFAULT_TURPLEOBJECT
      Turple.turpleobject = {
        :interactive => true,
        :configuration => {
          :destination => 'foo/destination',
        },
        :sources => {
          :foo_source => 'foo/source/path'
        }
      }

      allow(Turple).to receive(:load_turplefile)
      allow(Turple).to receive(:turpleobject=)
      allow_any_instance_of(Turple).to receive(:output_summary)
      allow(Turple::Source).to receive(:new)
      allow(Turple::Template).to receive(:new).and_return RecursiveOpenStruct.new({ :required_data => 'required_data' })
      allow(Turple::Data).to receive(:new).and_return 'data'
      allow(Turple::Interpolate).to receive(:new)

      @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
      @turple = Turple.new @template_path
    end

    after do
      allow(Turple).to receive(:load_turplefile).and_call_original
      allow(Turple).to receive(:turpleobject=).and_call_original
      allow_any_instance_of(Turple).to receive(:output_summary).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
      allow(Turple::Template).to receive(:new).and_call_original
      allow(Turple::Data).to receive(:new).and_call_original
      allow(Turple::Interpolate).to receive(:new).and_call_original
    end

    it 'should initialize in the right order' do
      # load the home turplefile to establish new custom defaults
      expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('~'), 'Turplefile')).ordered

      # AFTER HOME TURPLEFILE IS LOADED
      # create sources so the template can look through them
      expect(Turple::Source).to have_received(:new).with(:foo_source, 'foo/source/path').ordered

      # update turpleobject with initialized arguments
      expect(Turple).to have_received(:turpleobject=).with({
        :template => @template_path,
        :data => {},
        :configuration => {}
      }).ordered

      # AFTER SOURCES ARE CREATED
      # create the template so the configuration is updated
      expect(Turple::Template).to have_received(:new).with(@template_path, true).ordered

      # load destination turplefile for possible data
      expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('foo/destination'), 'Turplefile')).ordered

      # AFTER TEMPLATE
      # create the data instance
      expect(Turple::Data).to have_received(:new).with('required_data', Hash, Hash).ordered

      # AFTER TEMPLATE & DATA
      # create the interpolation instance
      expect(Turple::Interpolate).to have_received(:new).with(RecursiveOpenStruct, 'data', ending_with('foo/destination')).ordered

      # AFTER EVERYTHING
      # output the interpolation summary
      expect(@turple).to have_received(:output_summary).ordered
    end

    it 'should initialize all components' do
      expect(Turple::Interpolate).to have_received(:new).with instance_of(RecursiveOpenStruct), 'data', ending_with('foo/destination')
    end

    it 'should create sources from Turplefile' do
      expect(Turple::Source).to have_received(:new).with :foo_source, 'foo/source/path'
    end
  end

  describe '.load_turplefile' do
    before do
      allow(Turple).to receive(:turpleobject=)
    end

    before do
      allow(Turple).to receive(:turpleobject=).and_call_original
    end

    it 'should read Turplefile into turpleobject' do
      expect(Turple).to receive(:turpleobject=).once.with Hash

      Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'template', 'Turplefile')
    end
  end

  describe '.turpleobject=' do
    it 'should symbolize keys' do
      Turple.turpleobject = {
        'configuration' => {
          'foo' => {
            'bar' => 'baz'
          }
        }
      }

      expect(Turple.configuration[:foo][:bar]).to eq 'baz'
    end
  end
end
