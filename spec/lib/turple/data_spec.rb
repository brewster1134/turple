describe Turple::Data do
  before do
    required_data = {
      :foo => {
        :bar => {
          :baz => true,
          :bez => true,
          :biz => true
        }
      }
    }

    provided_data = {
      :foo => {
        :bar => {
          :baz => 'Baz'
        }
      }
    }

    data_map = {
      :foo => {
        :bar => {
          :bez => 'The name of the foo bar bez'
        }
      }
    }

    @data = Turple::Data.new required_data, provided_data, data_map
  end

  describe '#build_data_map' do
    it 'should augment the data map with missing values' do
      expect(@data.instance_var(:data_map)).to eq({
        :foo => {
          :bar => {
            :baz => [:foo, :bar, :baz],
            :bez => 'The name of the foo bar bez',
            :biz => [:foo, :bar, :biz]
          }
        }
      })
    end
  end

  describe '#missing_data' do
    it 'should compare required data with and provided data' do
      expect(@data.instance_var(:missing_data)).to eq({
        :foo => {
          :bar => {
            :bez => 'The name of the foo bar bez',
            :biz => [:foo, :bar, :biz]
          }
        }
      })
    end
  end
end
