# $Id: post_controller_test.rb 296 2007-01-30 22:31:51Z garrett $

require File.dirname(__FILE__) + '/../test_helper'
require 'post_controller'
$page_title = 'test' # for testing purposes

# Re-raise errors caught by the controller.
class PostController; def rescue_action(e) raise e end; end

class PostControllerTest < Test::Unit::TestCase
  
  fixtures :tags, :posts, :tags_posts

  def setup
    @controller = PostController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_pref_speed
    total = 0
    total2 = 0
    
    10.times do
      start = Time.now
      Preference.get_setting('domain')
      Preference.get_setting('site_name')
      Preference.get_setting('slogan')
      Preference.get_setting('site_description')
      Preference.get_setting('site_primary_author')
      Preference.get_setting('author_gender')
      Preference.get_setting('author_email')
      Preference.get_setting('email_subject')
      Preference.get_setting('error_page_title')
      Preference.get_setting('search_results')
      Preference.get_setting('items_on_index')
      Preference.get_setting('items_in_feed')
      Preference.get_setting('offset')
      Preference.get_setting('nice_dashes')
      Preference.get_setting('warn_bad_browsers')
      Preference.get_setting('show_author_of_post')
      Preference.get_setting('ping_by_default')
      Preference.get_setting('preview_by_default')
      Preference.get_setting('new_post_by_default')
      Preference.get_setting('time_format')
      Preference.get_setting('date_format')
      Preference.get_setting('copyright_year')
      Preference.get_setting('icbm')
      Preference.get_setting('issn')
      Preference.get_setting('esbn')
      Preference.get_setting('encoding')
      Preference.get_setting('language')
      Preference.get_setting('mint_dir')
      Preference.get_setting('delicious_username')
      Preference.get_setting('rss_url')
      Preference.get_setting('text_filter')
      Preference.get_setting('smarty_pants')
      Preference.get_setting('custom_field_1_on')
      Preference.get_setting('custom_field_2_on')
      Preference.get_setting('custom_field_3_on')
      Preference.get_setting('custom_field_1')
      Preference.get_setting('custom_field_2')
      Preference.get_setting('custom_field_3')
      Preference.get_setting('extended_link_text')
      Preference.get_setting('simple_titles')
      Preference.get_setting('current_theme')
      Preference.get_setting('encode_entities')
      eend = Time.now
      total += (eend-start)
      Preference.clear_hash
    end
    
    10.times do
      start = Time.now
      Site.domain
      Site.site_name
      Site.slogan
      Site.site_description
      Site.site_primary_author
      Site.author_gender
      Site.author_email
      Site.email_subject
      Site.error_page_title
      Site.search_results
      Site.items_on_index
      Site.items_in_feed
      Site.offset
      Site.nice_dashes
      Site.warn_bad_browsers
      Site.show_author_of_post
      Site.ping_by_default
      Site.preview_by_default
      Site.new_post_by_default
      Site.time_format
      Site.date_format
      Site.copyright_year
      Site.icbm
      Site.issn
      Site.esbn
      Site.encoding
      Site.language
      Site.mint_dir
      Site.delicious_username
      Site.rss_url
      Site.text_filter
      Site.smarty_pants
      Site.custom_field_1_on
      Site.custom_field_2_on
      Site.custom_field_3_on
      Site.custom_field_1
      Site.custom_field_2
      Site.custom_field_3
      Site.extended_link_text
      Site.simple_titles
      Site.current_theme
      Site.encode_entities
      eend = Time.now
      total2 += (eend-start)
      Preference.clear_hash
    end
  end
  
  def test_index
    get :list
    assert_response :success
    assert_template 'index'
    assert(@response.has_template_object?('tags'))
    assert(@response.has_template_object?('posts'))
  end
  
  def test_tag_archive
    get :tagged, :tag => tags(:tag_1).name
    assert_response :success
    assert_template 'by_tag'
    assert(@response.has_template_object?('tags'))
    assert(@response.has_template_object?('posts'))
    get :tagged, :tag => 'asdfsdfsdf' # doesn't exist
    assert_redirected_to '/'
  end
  
  def test_author_archive
    get :by_author, :id => 1
    assert_response :success
    assert_template 'by_author'
    assert(@response.has_template_object?('tags'))
    assert(@response.has_template_object?('posts'))
    get :by_author, :id => 12092 # doesn't exist
    assert_redirected_to '/'
  end
  
  def test_individual_post
    get :show, :year => 2006, :month => 5, :day => 1, :link => 'test_body_content'
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:post)
    assert_equal posts(:post_1), assigns(:post)[0] # just need the post part here
  end
  
  def test_feed_all
    get :feed_all_rss
    assert_response :success
    assert_template 'posts'
    assert(@response.has_template_object?('posts'))
  end
  
  def test_search
    # you can only run this if you run the post_controller_test.rb file directly,
    # there's a bug in rails 1.0 that doesn't respect your table type in the schema
    # when raking, and we need myISAM to be in effect to run this test.
    #
    # uncomment this test if you want to run it directly    
    #post :search, :q => 'test'
    #assert assigns(:posts).length > 0
    #assert_response :success
    #post :search, :q => 'qwerty'
    #assert_equal 0, assigns(:posts).length
    #assert_response :success
  end

end