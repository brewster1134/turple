require 'recursive-open-struct'

describe Turple do
  describe '#initialize' do
    before do
      Turple.class_var :turpleobject, DEFAULT_TURPLEOBJECT.deep_merge({
        :interactive => true,
        :sources => {
          :default => File.join(ROOT_DIR, 'spec', 'fixtures')
        },
        :configuration => {
          :destination => 'foo/destination'
        }
      })


      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_return({ :required_data => true })
      allow_any_instance_of(Turple).to receive(:output_summary).and_call_original
      allow(Turple).to receive(:load_turplefile).and_call_original
      allow(Turple).to receive(:turpleobject=).and_call_original
      allow(Turple::Source).to receive(:new)
      allow(Turple::Template).to receive(:new).and_return(OpenStruct.new({
        :required_data => { :required => 'data' },
        :name => 'foo_template'
      }))
      allow(Turple::Data).to receive(:new).and_return 'data'
      allow(Turple::Interpolate).to receive(:new).and_return(OpenStruct.new({
        :project_name => 'foo_project',
        :time => 1
      }))
    end

    after do
      allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
      allow(Turple::Template).to receive(:new).and_call_original
      allow(Turple::Data).to receive(:new).and_call_original
    end

    context 'with a template path' do
      before do
        @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
        @turple = Turple.new @template_path
      end

      it 'should initialize in the right order' do
        # load the home turplefile to establish new custom defaults
        expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('~'), 'Turplefile')).ordered

        # load the template turplefile to check for a template vs project
        expect(Turple).to have_received(:load_turplefile).with(File.join(@template_path, 'Turplefile'), false).ordered

        # AFTER HOME & TEMPLATE/PROJECT TURPLEFILE IS LOADED
        # create sources so the template can look through them
        expect(Turple::Source).to have_received(:new).with(:default, File.join(ROOT_DIR, 'spec', 'fixtures')).ordered

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
        expect(Turple::Data).to have_received(:new).with({ :required => 'data' }, Hash, Hash).ordered

        # AFTER TEMPLATE & DATA
        # create the interpolation instance
        expect(Turple::Interpolate).to have_received(:new).with(OpenStruct, 'data', ending_with('foo/destination')).ordered

        # AFTER EVERYTHING
        # output the interpolation summary
        expect(@turple).to have_received(:output_summary).ordered
      end
    end

    context 'with a project path' do
      before do
        @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'project')
        @turple = Turple.new @template_path
      end

      it 'should add the project sources' do
        expect(Turple.sources[:spec]).to eq 'spec/fixtures'
      end

      it 'should initialize with the project template' do
        expect(Turple::Template).to have_received(:new).with 'template', true
      end
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
