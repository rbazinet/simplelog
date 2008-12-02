# $Id: base_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/base_controller'

# Re-raise errors caught by the controller.
class Admin::BaseController; def rescue_action(e) raise e end; end

class BaseControllerTest < Test::Unit::TestCase
  
  fixtures :authors, :comments, :tags, :posts, :tags_posts
  
  def setup
    @controller = Admin::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_filter
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = nil
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = nil
    get :author_edit, :id => 1
    assert_response 302
    assert_redirected_to 'login'
  end
  
  def test_user_auth
    assert_equal false, Author.authorize('poop', 'badpass')
    assert_equal true, Author.authorize(authors(:garrett).email, authors(:garrett).hashed_pass)
  end
  
  def test_some_routes
    route = {:controller => 'admin/posts', :action => 'post_edit', :id => '1'}
    assert_routing 'admin/posts/edit/1', route
    route = {:controller => 'admin/tags', :action => 'tag_edit', :id => '1'}
    assert_routing 'admin/tags/edit/1', route
    route = {:controller => 'admin/authors', :action => 'author_update', :id => '1'}
    assert_routing 'admin/authors/update/1', route
    route = {:controller => 'admin/misc', :action => 'do_ping'}
    assert_routing 'admin/ping/do', route
    route = {:controller => 'xmlrpc', :action => 'api'}
    assert_routing 'xmlrpc/api', route
  end
  
end