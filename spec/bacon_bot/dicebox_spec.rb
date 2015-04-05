require 'bacon_bot/dicebox'

describe Dicebox::Dice do
  before :all do
    @dice = Dicebox::Dice.new('2d6')
  end

  context '#roll' do
    it 'should roll' do
      @dice.roll
    end
  end
end
