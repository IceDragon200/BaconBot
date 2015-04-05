require 'tmpdir'
require 'fileutils'
require 'bacon_bot/storage'

describe Bacon::Storage do
  before :all do
    @tmp = Dir.mktmpdir
    @store = Bacon::Storage.new(@tmp)
  end

  after :all do
    FileUtils.remove_entry_secure @tmp
  end

  context '#get' do
    it 'should create a new store' do
      @store.get('my_store') { ['egg'] }
    end

    it 'should retrieve an existing store' do
      expect(@store.get('my_store').data).to eq(['egg'])
    end
  end

  context '#save' do
    it 'should save a store' do
      s = @store.get('food') { ['egg', 'bread'] }
      s.data << 'cheese'
      s.save
      @store.clear
      expect(@store.get('food').data).to eq(['egg', 'bread', 'cheese'])
    end
  end
end
