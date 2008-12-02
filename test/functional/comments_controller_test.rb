# $Id: comments_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/comments_controller'

# Re-raise errors caught by the controller.
class Admin::CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  
  fixtures :authors, :posts, :comments
  
  def setup
    @controller = Admin::CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_comment_list
    get :comment_list
    assert_template 'comment_list'
    assert(@response.has_template_object?('comments'))
  end
  
  def test_comment_edit
    get :comment_edit, :id => 1
    assert_template 'comment_edit'
    assert(@response.has_template_object?('comment'))
    assert(assigns('comment').valid?)
    assert_response :success
  end
  
  def test_comment_update
    post :comment_update, :id => 1, :comment => {:is_approved => false}
    assert_redirected_to 'admin/comments'
    assert_equal 1, Comment.find(:all, :conditions => ['is_approved = ?', false]).length
    post :comment_update, :id => 1, :comment => {:is_approved => true}
  end
  
  def test_comment_destroy
    comment = Comment.find(1)
    assert_not_nil comment
    get :comment_destroy, :id => 1
    assert_redirected_to 'admin/comments'
    assert_raise(ActiveRecord::RecordNotFound) { a = Comment.find(1) }
  end
  
end