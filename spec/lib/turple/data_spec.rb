# class DataSpec
#   include Turple::Data
# end

# describe Turple::Data do
#   before do
#     @data = DataSpec.new
#   end

#   describe '#load' do
#     it 'should process yaml data' do
#       yaml_data_file = File.join(ROOT_DIR, 'spec', 'fixtures', 'data.yaml')

#       expect(@data.load(yaml_data_file).foo.bar).to eq 'baz'
#     end

#     it 'should process json data' do
#       json_data_file = File.join(ROOT_DIR, 'spec', 'fixtures', 'data.json')

#       expect(@data.load(json_data_file).foo.bar).to eq 'baz'
#     end

#     it 'should request user input for missing data' do
#       allow(@data).to receive(:prompt)
#       expect(@data.load(nil)).to have_received :prompt
#     end
#   end

#   describe '#scan' do
#     it 'should return all interpolation keys' do
#       template_dir = File.join(ROOT_DIR, 'spec', 'fixtures', 'dir_one_[FOO.BAR]')
#       keys = @data.scan template_dir

#       expect(keys).to eq({
#         foo: {
#           bar: nil
#         }
#       })
#     end
#   end
# end
