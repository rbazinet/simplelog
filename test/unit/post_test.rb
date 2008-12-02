# $Id: post_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  
  fixtures :tags, :posts, :tags_posts
  
  def test_create_post
    c = Post.count
    p = Post.new
    p.author_id = 1
    p.title = 'new test'
    p.body_raw = 'test body content'
    assert p.save
    assert_equal c+1, Post.count
  end
  
  def test_edit_post
    p = Post.find(1)
    title = p.title
    p.title = 'new title now'
    p.is_active = false
    assert p.save
    assert title != p.title
    assert_equal false, p.is_active
  end
  
  def test_destroy_post
    c = Post.count
    p = Post.find(1)
    assert p.destroy
    assert_equal c-1, Post.count
  end
  
  def test_get_active_posts
    # fixtures have 3 posts, 2 active
    c = Post.count # 3
    n = Post.count(:conditions => ['is_active = ?', true]) # 2
    assert_equal c, n+1
  end    
  
  def test_tag_post
    # let's turn off deprecation warnings for now
    ActiveSupport::Deprecation.silenced = true
    
    p = Post.find(1)
    c = p.tag_names.length
    assert p.tag('another')
    assert_equal c+1, p.tag_names.length
  end
  
  def test_remove_tags
    p = Post.find(1)
    assert p.tag('', :clear => true)
    assert_equal 0, p.tag_names.length
  end
  
  def test_permalinks
    # note that this test assumes you haven't changed the `extra_word` argument of Post.to_permalink
    # from the default 'again'... if you have, change the equality assertions below appropriately
    p = Post.new
    p.title = 'test post'
    p.body_raw = "this is my post content and it's a test"
    assert p.save
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'this_is_my_post_content' : 'test_post'), p.permalink

    # cleaning HTML...
    p = Post.new
    p.title = 'testing <b>post</b>'
    p.body_raw = "here's a strange <a href=\"test.html\">permalink</a> because it has a link"
    assert p.save
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'heres_a_strange_permalink_because' : 'testing_post'), p.permalink
  
    # duplicates?
    p = Post.new
    p.title = 'tested post'
    p.body_raw = "here's my test permalink"
    assert p.save
    n = Post.new
    n.title = 'tested post'
    n.body_raw = "here's my test permalink"
    assert n.save
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'heres_my_test_permalink' : 'tested_post'), p.permalink
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'heres_my_test_permalink_again' : 'tested_post_again'), n.permalink
    
    # HTML + duplicates?
    p = Post.new
    p.title = 'tester <b>post</b>'
    p.body_raw = "here's another strange <a href=\"test.html\">permalink</a> because it has a link"
    assert p.save
    n = Post.new
    n.title = 'tester <b>post</b>'
    n.body_raw = "here's another strange <a href=\"test.html\">permalink</a> because it has a link"
    assert n.save
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'heres_another_strange_permalink_because' : 'tester_post'), p.permalink
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'heres_another_strange_permalink_because_it' : 'tester_post_again'), n.permalink
    
    # short content + duplicates + duplicates
    p = Post.new
    p.title = 'one more test'
    p.body_raw = 'hi'
    assert p.save
    n = Post.new
    n.title = 'one more test'
    n.body_raw = 'hi'
    assert n.save
    a = Post.new
    a.title = 'one more test'
    a.body_raw = 'hi'
    a.save
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'hi' : 'one_more_test'), p.permalink
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'hi_again' : 'one_more_test_again'), n.permalink
    assert_equal (Preference.get_setting('SIMPLE_TITLES') == 'yes' ? 'hi_again_again' : 'one_more_test_again_again'), a.permalink
  end
  
end