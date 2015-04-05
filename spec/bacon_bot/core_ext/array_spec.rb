require 'bacon_bot/core_ext/array'

describe Array do
  context '#pick!' do
    it 'should sample and delete 1 element from the array' do
      ary = [1, 2, 3]
      ary.pick!
      expect(ary.size).to eq(2)
    end
  end
end
