# $Id: page_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  
  fixtures :pages

  def test_no_dups
    p = Page.new(:permalink => 'yo', :title => 'yo', :body_raw => 'okay')
    assert p.save
    p = Page.new(:permalink => 'yo', :title => 'yo', :body_raw => 'okay')
    assert !p.save
  end
  
  def test_create
    p = Page.new(:permalink => 'yo')
    assert !p.save
    p = Page.new(:permalink => 'yo', :title => 'yo', :body_raw => 'okay')
    assert p.save
  end
  
  def test_reserved_words
    p = Page.new(:permalink => 'show', :title => 'yo', :body_raw => 'okay')
    assert !p.save
  end
  
end