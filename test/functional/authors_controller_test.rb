# $Id: authors_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/authors_controller'

# Re-raise errors caught by the controller.
class Admin::AuthorsController; def rescue_action(e) raise e end; end

class AuthorsControllerTest < Test::Unit::TestCase
  
  fixtures :authors, :posts
  
  def setup
    @controller = Admin::AuthorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_author_list
    get :author_list
    assert_template 'author_list'
    assert(@response.has_template_object?('authors'))
  end
  
  def test_author_new
    get :author_new
    assert_template 'author_new'
    assert(@response.has_template_object?('author'))
    assert_response :success
  end
  
  def test_author_create
    c = Author.count
    post :author_create, :author => {:name => 'test', :email => 'test@test.com', :password => 'test'}
    assert_redirected_to 'admin/authors'
    assert_equal c+1, Author.count
  end
  
  def test_author_edit
    get :author_edit, :id => 1
    assert_template 'author_edit'
    assert(@response.has_template_object?('author'))
    assert(assigns('author').valid?)
    assert_response :success
  end
  
  def test_author_update
    post :author_update, :id => 1
    assert_redirected_to 'admin/authors'
    post :author_update, :id => 3, :author => {:is_active => '0'}
    assert_redirected_to 'admin/authors'
    assert_equal 1, Author.find(:all, :conditions => 'is_active = true').length
    post :author_update, :id => 1, :author => {:is_active => '0'} # shouldn't able to
    assert_equal 1, Author.find(:all, :conditions => 'is_active = true').length
  end
  
  def test_author_destroy
    author = Author.find(3)
    assert_not_nil author
    pc = author.posts.count
    assert_equal 3, pc
    get :author_destroy, :id => 3
    assert_redirected_to 'admin/authors'
    assert_raise(ActiveRecord::RecordNotFound) { a = Author.find(3) }
    assert_equal 0, Post.find(:all, :conditions => 'author_id = 3').length
    # now we only have one active author, so we shouldn't be able to destroy another
    c = Author.count # 2
    get :author_destroy, :id => 1
    assert_redirected_to 'admin/authors'
    assert_equal c, Author.count
    # now we set the inactive author active and we should be able to delete it
    assert Author.find(2).update_attribute('is_active', true)
    get :author_destroy, :id => 1
    assert_equal 1, Author.count
  end
  
end