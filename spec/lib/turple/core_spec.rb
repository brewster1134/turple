describe Turple::Core do
  describe '#initialize' do
    before do
      @core_instance = Turple::Core.allocate
      allow(@core_instance).to receive(:interpolate)
      allow(Turple::Core).to receive(:load_turplefile)
      allow(Turple::Source).to receive(:new)
    end

    after do
      allow(Turple::Core).to receive(:load_turplefile).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
      allow(Turple::Template).to receive(:find).and_call_original
      allow(Turple::Template).to receive(:new).and_call_original
    end

    context 'when source is passed' do
      before do
        @core_instance.send :initialize, source: 'source_location'
      end

      it 'should initialize a source' do
        expect(Turple::Source).to have_received(:new).with 'source_location', :user
      end
    end

    context 'when template is passed as a string' do
      context 'when a source is passed' do
        before do
          @source_instance = instance_double Turple::Source
          @template_instance = instance_double Turple::Template

          allow(@source_instance).to receive(:templates).and_return user_source_template_name: 'local_source_template_path'
          allow(Turple::Source).to receive(:new).and_return @source_instance
          allow(Turple::Template).to receive(:find)
          allow(Turple::Template).to receive(:new).and_return @template_instance

          @core_instance.send :initialize, template: 'user_source_template_name', source: 'source_location'
        end

        it 'should not search the sources' do
          expect(Turple::Template).to_not have_received(:find).with 'user_source_template_name'
        end

        it 'should initialize a template' do
          expect(Turple::Template).to have_received(:new).with 'local_source_template_path'
        end

        it 'should interpolate with the source template' do
          expect(@core_instance).to have_received(:interpolate).with @template_instance, nil
        end
      end

      context 'when a source is not passed' do
        before do
          @template_instance = instance_double Turple::Template

          allow(Turple::Template).to receive(:find).and_return 'local_template_path'
          allow(Turple::Template).to receive(:new).and_return @template_instance

          @core_instance.send :initialize, template: 'user_template_name'
        end

        it 'should search the sources for the template' do
          expect(Turple::Template).to have_received(:find).with 'user_template_name'
        end

        it 'should initialize a template' do
          expect(Turple::Template).to have_received(:new).with 'local_template_path'
        end

        it 'should interpolate with the template' do
          expect(@core_instance).to have_received(:interpolate).with @template_instance, nil
        end
      end
    end

    context 'when project is passed as a string' do
      before do
        allow(Turple::Project).to receive(:new)

        @core_instance.send :initialize, project: 'local_project_path'
      end

      after do
        allow(Turple::Project).to receive(:new).and_call_original
      end

      it 'should initialize a project' do
        expect(Turple::Project).to have_received(:new).with 'local_project_path'
      end
    end

    context 'when Template and Project objects exist' do
      before do
        @template_instance = instance_double Turple::Template
        @project_instance = instance_double Turple::Project

        @core_instance.send :initialize, template: @template_instance, project: @project_instance
      end

      it 'should load home Turplefile' do
        expect(Turple::Core).to have_received(:load_turplefile).with '~'
      end

      it 'should interpolate the template to the project' do
        expect(@core_instance).to have_received(:interpolate).with @template_instance, @project_instance
      end
    end
  end

  describe '#load_turplefile' do
    before do
      allow(File).to receive(:read).and_return('foo: bar')
    end

    after do
      allow(File).to receive(:read).and_call_original
    end

    it 'should try to read the absolute path' do
      turplefile_path = File.join(File.expand_path('~'), 'Turplefile')
      expect(File).to receive(:read).with turplefile_path

      Turple::Core.load_turplefile '~'
    end

    context 'when sources exist' do
      before do
        allow(Turple::Source).to receive(:new)
        allow(YAML).to receive(:load).and_return({
          sources: {
            foo: 'foo_source',
            bar: 'bar_source'
          }
        })

        Turple::Core.load_turplefile '~'
      end

      after do
        allow(Turple::Source).to receive(:new).and_call_original
      end

      it 'should initialize each source' do
        expect(Turple::Source).to have_received(:new).exactly(2).times
        expect(Turple::Source).to have_received(:new).with 'foo_source', :foo
        expect(Turple::Source).to have_received(:new).with 'bar_source', :bar
      end
    end

    context 'when project/template exists' do
      before do
        allow(Turple::Core).to receive(:settings=)
        allow(YAML).to receive(:load).and_return({ foo: 'foo' })

        Turple::Core.load_turplefile '~'
      end

      after do
        allow(Turple::Core).to receive(:settings=).and_call_original
      end

      it 'should update the settings' do
        expect(Turple::Core).to have_received(:settings=).with({ foo: 'foo' })
      end
    end
  end

  describe '#settings=' do
    before do
      Turple::Core.class_variable_set :@@settings, {}

      Turple::Core.settings=({
        'foo' => 'foo',
        'project' => {
          'fname' => 'John'
        }
      })

      Turple::Core.settings=({
        'bar' => 'bar',
        'project' => {
          'fname' => 'Jane',
          'lname' => 'Doe'
        }
      })
    end

    it 'should merge into the global settings' do
      expect(Turple::Core.settings).to eq({
        foo: 'foo',
        bar: 'bar',
        project: {
          fname: 'Jane',
          lname: 'Doe'
        }
      })
    end
  end
end

# require 'recursive-open-struct'
#
# describe Turple::Core do
#   describe '#initialize' do
#     before do
#       allow(Turple::Settings).to receive :new
#       allow(Turple::Source).to receive :find_source_by_name
#       allow(Turple::Source).to receive :find_template_by_name
#       allow(Turple::Source).to receive :new
#       allow(Turple::Project).to receive :new
#     end
#
#     after do
#       allow(Turple::Settings).to receive(:new).and_call_original
#       allow(Turple::Source).to receive(:find_source_by_name).and_call_original
#       allow(Turple::Source).to receive(:find_template_by_name).and_call_original
#       allow(Turple::Source).to receive(:new).and_call_original
#       allow(Turple::Project).to receive(:new).and_call_original
#     end
#
#     # various source & template combinations
#     context 'when user passes SOURCE and TEMPLATE' do
#       before do
#         @cli = Turple::Cli.new
#         @cli.options({
#           source: 'user_source',
#           template: 'user_template'
#         })
#         @cli.ate
#       end
#
#       it 'should init the users source' do
#         expect(Turple::Source).to receive(:new).with 'user_source'
#       end
#
#       context 'when SOURCE is valid' do
#         context 'when TEMPLATE exists in SOURCE' do
#           before do
#             allow(Turple::Source).to receive(:new).and_return RecursiveOpenStruct.new valid?: true, templates: { user: 'user_template' }
#           end
#
#           it 'should init the users template' do
#             expect(Turple::Template).to receive(:new).with :user, 'user_template'
#           end
#         end
#       end
#
#       context 'when SOURCE is invalid' do
#         before do
#           allow(Turple::Source).to receive(:new).and_return RecursiveOpenStruct.new valid?: false
#         end
#
#         it 'should init the default templates' do
#           expect(Turple::Template).to receive(:new).with 'user_template'
#         end
#
#         context 'when TEMPLATE exists in other sources' do
#           # pass in that source
#           # pass in template
#         end
#
#         context 'when TEMPLATE does not exist in default sources' do
#           # request source until valid & has template
#           # init source
#           # pass in template
#         end
#       end
#     end
#
#     context 'when user passes SOURCE but no template' do
#       context 'when SOURCE is valid' do
#         # request user choose from list of templates
#         # init source
#         # pass in template
#       end
#
#       context 'when SOURCE is invalid' do
#         # request source until valid
#         # request user choose from list of templates
#         # init source
#         # pass in template
#       end
#     end
#
#     context 'when user passes no source but passes a TEMPLATE' do
#       # init default sources
#
#       context 'when TEMPLATE exists in default sources' do
#         # pass in that source
#         # pass in template
#       end
#
#       context 'when TEMPLATE does not exist in default sources' do
#         # request source until valid & has template
#         # init source
#         # pass in template
#       end
#     end
#
#     context 'when user passes no source or template' do
#       # request template
#       # request source until valid & has template
#       # init source
#       # pass in template
#     end
#   end
# end
#
#
#
#
#
# xdescribe "OLD" do
#   describe '#initialize' do
#     before do
#       Turple.class_var :settings, DEFAULT_SETTINGS.deep_merge({
#         :interactive => true,
#         :sources => {
#           :default => File.join(ROOT_DIR, 'spec', 'fixtures')
#         },
#         :configuration => {
#           :destination => 'foo/destination'
#         }
#       })
#
#
#       allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_return({ :required_data => true })
#       allow_any_instance_of(Turple).to receive(:output_summary).and_call_original
#       allow(Turple).to receive(:load_turplefile).and_call_original
#       allow(Turple).to receive(:settings=).and_call_original
#       allow(Turple::Source).to receive(:new)
#       allow(Turple::Template).to receive(:new).and_return(OpenStruct.new({
#         :required_data => { :required => 'data' },
#         :name => 'foo_template'
#       }))
#       allow(Turple::Data).to receive(:new).and_return 'data'
#       allow(Turple::Interpolate).to receive(:new).and_return(OpenStruct.new({
#         :project_name => 'foo_project',
#         :time => 1
#       }))
#     end
#
#     after do
#       allow_any_instance_of(Turple::Template).to receive(:scan_for_data).and_call_original
#       allow(Turple::Source).to receive(:new).and_call_original
#       allow(Turple::Template).to receive(:new).and_call_original
#       allow(Turple::Data).to receive(:new).and_call_original
#     end
#
#     context 'with a template path' do
#       before do
#         @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'template')
#         @turple = Turple.new @template_path
#       end
#
#       it 'should initialize in the right order' do
#         # load the home turplefile to establish new custom defaults
#         expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('~'), 'Turplefile')).ordered
#
#         # load the template turplefile to check for a template vs project
#         expect(Turple).to have_received(:load_turplefile).with(File.join(@template_path, 'Turplefile'), false).ordered
#
#         # AFTER HOME & TEMPLATE/PROJECT TURPLEFILE IS LOADED
#         # create sources so the template can look through them
#         expect(Turple::Source).to have_received(:new).with(:default, File.join(ROOT_DIR, 'spec', 'fixtures')).ordered
#
#         # update settings with initialized arguments
#         expect(Turple).to have_received(:settings=).with({
#           :template => @template_path,
#           :data => {},
#           :configuration => {}
#         }).ordered
#
#         # AFTER SOURCES ARE CREATED
#         # create the template so the configuration is updated
#         expect(Turple::Template).to have_received(:new).with(@template_path, true).ordered
#
#         # load destination turplefile for possible data
#         expect(Turple).to have_received(:load_turplefile).with(File.join(File.expand_path('foo/destination'), 'Turplefile')).ordered
#
#         # AFTER TEMPLATE
#         # create the data instance
#         expect(Turple::Data).to have_received(:new).with({ :required => 'data' }, Hash, Hash).ordered
#
#         # AFTER TEMPLATE & DATA
#         # create the interpolation instance
#         expect(Turple::Interpolate).to have_received(:new).with(OpenStruct, 'data', ending_with('foo/destination')).ordered
#
#         # AFTER EVERYTHING
#         # output the interpolation summary
#         expect(@turple).to have_received(:output_summary).ordered
#       end
#     end
#
#     context 'with a project path' do
#       before do
#         @template_path = File.join(ROOT_DIR, 'spec', 'fixtures', 'project')
#         @turple = Turple.new @template_path
#       end
#
#       it 'should add the project sources' do
#         expect(Turple.sources[:spec]).to eq 'spec/fixtures'
#       end
#
#       it 'should initialize with the project template' do
#         expect(Turple::Template).to have_received(:new).with 'template', true
#       end
#     end
#   end
#
#   describe '.load_turplefile' do
#     before do
#       allow(Turple).to receive(:settings=)
#     end
#
#     before do
#       allow(Turple).to receive(:settings=).and_call_original
#     end
#
#     it 'should read Turplefile into settings' do
#       expect(Turple).to receive(:settings=).once.with Hash
#
#       Turple.load_turplefile File.join(ROOT_DIR, 'spec', 'fixtures', 'template', 'Turplefile')
#     end
#   end
#
#   describe '.settings=' do
#     it 'should symbolize keys' do
#       Turple.settings = {
#         'configuration' => {
#           'foo' => {
#             'bar' => 'baz'
#           }
#         }
#       }
#
#       expect(Turple.configuration[:foo][:bar]).to eq 'baz'
#     end
#   end
# end