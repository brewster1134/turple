describe Hash do
  describe '.-' do
    context 'when nested hash exists' do
      it 'should diff recursively' do
        hash_one = { foo: :foo, bar: { foo: :foo, bar: :bar }}
        hash_two = { foo: :foo, bar: { foo: :foo }}
        expect(hash_one - hash_two).to eq({ bar: { bar: :bar }})
      end
      
      it 'should remove empty key with an empty hash' do
        hash_one = { foo: :foo, bar: { foo: :foo }}
        hash_two = { foo: :bar, bar: { foo: :foo }}
        expect(hash_one - hash_two).to eq({ foo: :foo })
      end
    end
    
    context 'when keys and values match' do
      it 'should remove the match' do
        hash_one = { foo: :foo, bar: :bar }
        hash_two = { foo: :bar, bar: :bar }
        expect(hash_one - hash_two).to eq({ foo: :foo })
      end
    end
    
    context 'when keys match, but values differ' do
      it 'should not remove key/value' do
        hash_one = { foo: :foo }
        hash_two = { foo: :bar }
        expect(hash_one - hash_two).to eq({ foo: :foo })
      end
    end
    
    context 'when keys exist only in secondary hash' do
      it 'should not include the key' do
        hash_one = { foo: :foo }
        hash_two = { bar: :bar }
        expect(hash_one - hash_two).to eq({ foo: :foo })
      end
    end
  end
  
  describe '.to_s' do
    context 'when nested hash exists' do
      it 'should collect the parent keys' do
        expect({ bar: { baz: :baz }, foo: :foo }.to_s).to eq 'bar.baz: baz, foo: foo'
      end
    end
    
    it 'should join keys and values' do
      expect({ foo: :foo, bar: :bar }.to_s).to eq 'foo: foo, bar: bar'
    end
  end
end

describe Turple do
  describe '#ate' do
    before do
      allow(Turple::Core).to receive(:load_turplefile)
      allow(Turple::Core).to receive(:new)
      allow(Turple::Source).to receive(:new)

      Turple.ate foo: 'foo'
    end

    after do
      allow(Turple::Core).to receive(:load_turplefile).and_call_original
      allow(Turple::Core).to receive(:new).and_call_original
      allow(Turple::Source).to receive(:new).and_call_original
    end

    it 'should start Turple' do
      expect(Turple::Source).to have_received(:new).with('brewster1134/turple-templates').ordered
      expect(Turple::Core).to have_received(:load_turplefile).with(ENV['HOME']).ordered
      expect(Turple::Core).to have_received(:new).with({ foo: 'foo' }).ordered
    end
  end
end
