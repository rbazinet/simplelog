# $Id: author_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'author_controller'
$page_title = 'test' # for testing purposes

# Re-raise errors caught by the controller.
class AuthorController; def rescue_action(e) raise e end; end

class AuthorControllerTest < Test::Unit::TestCase
  
  fixtures :authors
  
  def setup
    @controller = AuthorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_login
    get :login
    assert_template 'login'
    assert(@response.has_template_object?('author'))
    assert(@response.has_template_object?('tags'))
    assert_response :success
  end
  
  def test_do_login
    post :do_login, :id => 1, :author => {:email => 'test', :password => 'test'} # bad
    assert_redirected_to '/login'
    post :do_login, :author => {:email => 'garrett@email.com', :password => 'test'}
    assert_redirected_to '/admin'
    session[:came_from] = '/admin/posts' # alternative redirect
    post :do_login, :author => {:email => 'garrett@email.com', :password => 'test'}
    assert_redirected_to '/admin/posts'
  end
  
  def test_logout
    get :logout
    assert_redirected_to '/'
  end
  
end