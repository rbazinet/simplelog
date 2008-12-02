# $Id: update_test.rb 229 2006-08-23 18:02:08Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class UpdateTest < Test::Unit::TestCase
  
  fixtures :updates

  def test_check_updates
    u = Update.find(1)
    assert_equal false, u.update_available
  end
  
end