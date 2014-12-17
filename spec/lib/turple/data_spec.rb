describe Turple::Data do
  before do
    allow_any_instance_of(Turple::Data).to receive(:build_data_map)
    allow_any_instance_of(Turple::Data).to receive(:missing_data).and_return({})
    allow_any_instance_of(Turple::Data).to receive(:prompt_for_data)
    @data = Turple::Data.new({}, {})
  end

  after do
    allow_any_instance_of(Turple::Data).to receive(:build_data_map).and_call_original
    allow_any_instance_of(Turple::Data).to receive(:missing_data).and_call_original
    allow_any_instance_of(Turple::Data).to receive(:prompt_for_data).and_call_original
  end

  describe '#build_data_map' do
    before do
      allow_any_instance_of(Turple::Data).to receive(:build_data_map).and_call_original

      @required_data = {
        :foo => {
          :bar => {
            :baz => true,
            :bez => true
          }
        }
      }

      @data_map = {
        :foo => {
          :bar => {
            :bez => 'The name of the foo bar bez'
          }
        }
      }
    end

    it 'should augment the data map with missing values' do
      expect(@data.send :build_data_map, @required_data, @data_map).to eq({
        :foo => {
          :bar => {
            :baz => [:foo, :bar, :baz],
            :bez => 'The name of the foo bar bez'
          }
        }
      })
    end
  end

  describe '#missing_data' do
    before do
      allow_any_instance_of(Turple::Data).to receive(:missing_data).and_call_original

      @required_data = {
        :foo => {
          :bar => {
            :baz => true,
            :bez => true
          }
        }
      }

      @provided_data = {
        :foo => {
          :bar => {
            :bez => 'Bez'
          }
        }
      }

      @data_map = {
        :foo => {
          :bar => {
            :baz => 'Name of the foo bar baz',
            :bez => 'Name of the foo bar bez'
          }
        }
      }
    end

    it 'should compare required data with and provided data' do
      expect(@data.send :missing_data, @required_data, @provided_data, @data_map).to eq({
        :foo => {
          :bar => {
            :baz => 'Name of the foo bar baz'
          }
        }
      })
    end
  end

  describe '#prompt_for_data' do
    before do
      allow_any_instance_of(Turple::Data).to receive(:prompt_for_data).and_call_original
      allow(A).to receive(:sk).and_yield('Mr. Baz')#.and_yield('Mr. Poo')

      @data.instance_var :provided_data, {
        :user => 'data'
      }

      @missing_data = ({
        :foo => {
          :bar => {
            :baz => 'Name of the foo bar baz'
          }
        },
        :baz => 'Name of the baz'
      })

      @data.send :prompt_for_data, @missing_data
    end

    it 'should prompt for missing data' do
      expect(A).to have_received(:sk).twice
      expect(A).to have_received(:sk).with('Name of the foo bar baz')
      expect(A).to have_received(:sk).with('Name of the baz')
    end

    it 'should add data to provided data' do
      expect(@data.instance_var(:provided_data)).to eq({
        :foo => {
          :bar => {
            :baz => 'Mr. Baz'
          }
        },
        :baz => 'Mr. Baz',
        :user => 'data'
      })
    end
  end
end
