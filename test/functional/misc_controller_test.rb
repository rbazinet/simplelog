# $Id: misc_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'admin/misc_controller'

# Re-raise errors caught by the controller.
class Admin::MiscController; def rescue_action(e) raise e end; end

class MiscControllerTest < Test::Unit::TestCase
  
  fixtures :authors
  
  def setup
    @controller = Admin::MiscController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # let's set cookies for authentication so that we can do tests... the admin section is protected
    @request.cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_EMAIL_COOKIE], authors(:garrett).email)
    @request.cookies[SL_CONFIG[:USER_HASH_COOKIE]] = CGI::Cookie.new(SL_CONFIG[:USER_HASH_COOKIE], authors(:garrett).hashed_pass)
  end
  
  def test_misc
    assert_equal(1, 1)
  end
  
end