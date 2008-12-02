# $Id: tags_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/tags_controller'

# Re-raise errors caught by the controller.
class Admin::TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < Test::Unit::TestCase
  
  fixtures :authors, :posts, :tags
  
  def setup
    @controller = Admin::TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_tag_list
    get :tag_list
    assert_template 'tag_list'
    assert(@response.has_template_object?('tags'))
  end
  
  def test_tag_new
    get :tag_new
    assert_template 'tag_new'
    assert(@response.has_template_object?('tag'))
    assert_response :success
  end
  
  def test_tag_create
    c = Tag.count
    post :tag_create, :tag => {:name => 'testtag'}
    assert_redirected_to '/admin/tags'
    assert_equal c+1, Tag.count
  end
  
  def test_tag_edit
    get :tag_edit, :id => 1
    assert_template 'tag_edit'
    assert(@response.has_template_object?('tag'))
    assert(assigns('tag').valid?)
    assert_response :success
  end
  
  def test_tag_update
    post :tag_update, :id => 1, :tag => {:name => 'testagain'}
    assert_redirected_to '/admin/tags'
  end
  
  def test_tag_update_merge
    c = Tag.count
    post :tag_update, :id => 1, :tag => {:name => 'gtest'}
    assert_equal c, Tag.count
    post :tag_update, :id => 2, :old_name => 'tag_two', :tag => {:name => 'gtest'}
    assert_equal c-1, Tag.count # once merged, there will be one less tag
  end
  
  def test_tag_destroy
    assert_not_nil Tag.find(1)
    get :tag_destroy, :id => 1
    assert_redirected_to '/admin/tags'
    assert_raise(ActiveRecord::RecordNotFound) { t = Tag.find(1) }
  end
  
end