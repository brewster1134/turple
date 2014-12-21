describe Turple::Data do
  before do
    values = ['Required Mapped', 'Required']
    allow(A).to receive(:sk) do |&block|
      block.call values.shift
    end

    # LEGEND
    # Required, Provided, Mapped

    required_data = {
      :rpm => true,
      :rp => true,
      :rm => true,
      :r => true
    }

    provided_data = {
      :rpm => 'Required Provided Mapped',
      :rp => 'Required Provided'
    }

    data_map = {
      :rpm => 'What is Required Provided Mapped?',
      :rm => 'What is Required Mapped?'
    }

    @data = Turple::Data.new required_data, provided_data, data_map
  end

  after do
    allow(A).to receive(:sk).and_call_original
  end

  it 'should return all required data' do
    expect(@data.data.to_hash).to eq({
      :rpm => 'Required Provided Mapped',
      :rp => 'Required Provided',
      :rm => 'Required Mapped',
      :r => 'Required'
    })
  end

  it 'should prompt for missing data' do
    expect(A).to have_received(:sk).twice
    expect(A).to have_received(:sk).with 'What is Required Mapped?', anything
    expect(A).to have_received(:sk).with 'r', anything
  end
end
