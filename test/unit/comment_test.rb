# $Id: comment_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  
  fixtures :comments, :blacklist

  def test_kill_tags
    str = Comment.kill_tags('<this>is<great>')
    assert_equal('is', str)
  end
  
  def test_create
    c = Comment.new(:body => 'test')
    assert !c.save
    c = Comment.new(:body_raw => 'test', :post_id => '1', :email => 'ttt')
    assert !c.save
    c = Comment.new(:body_raw => 'test', :post_id => '1', :email => 'ttt@ttt.com')
    assert c.save
  end
  
  def test_spam_filter
    Blacklist.new(:item => 'ttt@ttt.com').save
    c = Comment.new(:body_raw => 'test', :post_id => '1', :email => 'ttt@ttt.com')
    assert !c.save
    Blacklist.delete_all
    c = Comment.new(:body_raw => 'test', :post_id => '1', :email => 'ttt@ttt.com')
    assert c.save
    Blacklist.new(:item => 'tt[0-9]+').save
    c = Comment.new(:body_raw => 'tt', :post_id => '1', :email => 'ttt@ttt.com')
    assert c.save
    c = Comment.new(:body_raw => 'tt8', :post_id => '1', :email => 'ttt@ttt.com')
    assert !c.save
  end
  
end