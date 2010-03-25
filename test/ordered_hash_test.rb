require 'test_helper'

class OrderedHashTest < Test::Unit::TestCase

  context 'An OrderedHash' do
    setup do
      @hash = Zafu::OrderedHash.new
      @hash[:a] = 1
      @hash[:c] = 2
      @hash[:b] = 3
    end

    should 'keep keys in insertion order' do
      assert_equal [:a, :c, :b], @hash.keys
    end
    
    should 'list each in insertion order' do
      res = []
      @hash.each do |k, v|
        res << v
      end
      assert_equal [1, 2, 3], res
    end
    
    should 'remove entry on delete' do
      @hash.delete(:c)
      assert_equal [:a, :b], @hash.keys
    end
  end
end