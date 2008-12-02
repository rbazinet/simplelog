# $Id: blacklist_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class BlacklistTest < Test::Unit::TestCase
  
  fixtures :blacklist
  
  def test_add_item
    bl = Blacklist.new
    assert !bl.save
    bl.item = 'giddyup.com'
    assert bl.save
  end
  
  def test_add_to_cache
    assert_equal([], Blacklist.cache)
    Blacklist.add_to_cache(Blacklist.new(:item => 'nownownow.com'))
    assert_equal(1, Blacklist.cache.length)
  end
  
  def test_empty_cache
    assert_equal(1, Blacklist.cache.length)
    Blacklist.delete_from_cache(Blacklist.new(:item => 'nownownow.com'))
    assert_equal([], Blacklist.cache)
    Blacklist.add_to_cache(Blacklist.new(:item => '111'))
    Blacklist.add_to_cache(Blacklist.new(:item => '222'))
    assert_equal(2, Blacklist.cache.length)
    Blacklist.clear_cache
    assert_equal([], Blacklist.cache)
  end
  
end
