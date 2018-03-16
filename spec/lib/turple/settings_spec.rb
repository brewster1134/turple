# describe Turple::Settings do
#   context 'in interactive mode' do
#     describe '.initialize' do
#       it 'should attempt to load multiple Turplefiles' do
#         expect(subject).to receive(:load_turplefile).ordered.with ENV['HOME']
#         expect(subject).to receive(:load_turplefile).ordered.with __dir__
#       end
#     end
#   end
# end
