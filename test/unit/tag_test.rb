# $Id: tag_test.rb 37 2006-05-01 22:34:37Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  
  fixtures :tags
  
  def test_create_tag
    c = Tag.count
    t = Tag.new
    t.name = 'another'
    assert t.save
    assert_equal c+1, Tag.count
  end
  
  def test_delete_tag
    c = Tag.count
    t = Tag.find(1)
    assert t.destroy
    assert_equal c-1, Tag.count
  end
  
  def test_rename_tag
    t = Tag.find(1)
    old_name = t.name
    t.name = 'new name'
    assert t.save
    assert old_name != Tag.find(1).name
  end
  
end