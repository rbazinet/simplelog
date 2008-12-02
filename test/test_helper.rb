# $Id: test_helper.rb 50 2006-05-04 19:04:18Z garrett $

ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase

  self.use_transactional_fixtures = false # we're using MyISAM in places, so we can't do this
  self.use_instantiated_fixtures  = false # faster if we don't instantiate these
  
end