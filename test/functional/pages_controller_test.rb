# $Id: pages_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/pages_controller'

# Re-raise errors caught by the controller.
class Admin::PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  
  fixtures :authors, :pages
  
  def setup
    @controller = Admin::PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_page_list
    get :page_list
    assert_template 'page_list'
    assert(@response.has_template_object?('pages'))
  end

  # def test_page_edit
  #   get :page_edit, :id => 1
  #   assert_template 'page_edit'
  #   assert(@response.has_template_object?('page'))
  #   assert(assigns('page').valid?)
  #   assert_response :success
  # end

  # def test_page_update
  #   post :page_update, :id => 1, :page => {:is_active => false}
  #   assert_redirected_to 'admin/pages'
  #   assert_equal 1, Page.find(:all, :conditions => ['is_active = ?', false]).length
  #   post :page_update, :id => 1, :page => {:is_active => true}
  # end

  def test_page_destroy
    page = Page.find(1)
    assert_not_nil page
    get :page_destroy, :id => 1
    assert_redirected_to 'admin/pages'
    assert_raise(ActiveRecord::RecordNotFound) { a = Page.find(1) }
  end
  
end