# $Id: author_test.rb 50 2006-05-04 19:04:18Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class AuthorTest < Test::Unit::TestCase
  
  fixtures :authors
  
  def test_authorization
    assert_equal authors(:garrett), Author.authorize('garrett@email.com', 'test', true, true)
  end
  
  def test_create_complete
    author = Author.new
    assert !author.save
    author = Author.new
    author.name = 'test'
    assert !author.save
    author = Author.new
    author.name = 'test'
    author.email = 'test@test.com'
    assert !author.save
    author = Author.new
    author.name = 'test'
    author.email = 'test@teset.com'
    author.password = 'test'
    assert author.save
  end
  
  def test_unique_emails
    author = Author.new
    author.name = 'test'
    author.email = 'garrett@email.com'
    author.password = 'test'
    assert !author.save
  end
  
  def test_change_pass
    author = Author.find(2)
    old_pass = author.hashed_pass
    author.password = 'different'
    assert author.save
    assert old_pass != author.hashed_pass
  end
  
  def test_keep_pass
    author = Author.find(1)
    old_pass = author.hashed_pass
    author.save
    author = Author.find(1)
    new_pass = author.hashed_pass
    assert_equal old_pass, new_pass
  end
  
  def test_hash
    author = Author.new
    author.name = 'test'
    author.email = 'test@test.com'
    author.password = 'here_is_my_pass'
    assert author.save
    assert_equal '9ca450839dab074c48794e9b073a173d1ef008d3', author.hashed_pass
  end
  
  def test_destroy_author
    c = Author.count
    author = Author.find(1)
    assert author.destroy
    assert_equal c-1, Author.count
  end
  
end