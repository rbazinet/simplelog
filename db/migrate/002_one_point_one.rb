# $Id: 002_one_point_one.rb 330 2007-02-14 19:06:13Z garrett $

#
# this migration for 1.1 creates the preferences table and fills it
# with default values, or, in the case of an upgrade, fills it with
# the current values in config/site.rb
#

require 'server.rb'

class OnePointOne < ActiveRecord::Migration
  def self.up
    create_table "preferences" do |t|
      t.column "nice_name", :string, :null => false
      t.column "description", :text, :null => false
      t.column "name", :string, :null => false
      t.column "value", :string, :null => false
    end
    
    # let's check if they've run simplelog 1.0 before, assume they have
    upgrade = true
    begin
    # try to require a 1.0 only file
      require File.dirname(__FILE__ + '../../config/site.rb')
    rescue LoadError
    # they don't have it, this is a new install of 1.1+, require new file
      upgrade = false
    end
    
    # we need some nice names and descriptions for the preferences for use in the admin section
    # so let's do that now (we'll need two copies, so save them into vars)    

    # nice_names
    nn1  = 'Domain'
    nn2  = 'Site name'
    nn3  = 'Slogan'
    nn4  = 'Site description'
    nn5  = 'Site owner'
    nn6  = 'Owner gender'
    nn7  = 'Owner email'
    nn8  = 'Email subject'
    nn9  = 'Error page title'
    nn10 = 'Items in search results'
    nn11 = 'Items on index'
    nn12 = 'Items in feed'
    nn13 = 'Local time'
    nn14 = 'Nice dashes?'
    nn15 = 'Warn bad browsers?'
    nn16 = 'Show authors?'
    nn17 = 'Ping by default?'
    nn18 = 'Preview by default?'
    nn19 = 'New post by default?'
    nn20 = 'Time format'
    nn21 = 'Date format'
    nn22 = 'Copyright year'
    nn23 = 'ICBM'
    nn24 = 'ISSN'
    nn25 = 'ESBN'
    nn26 = 'Encoding'
    nn27 = 'Language code'
    nn28 = 'Mint directory'
    nn29 = 'Del.icio.us username'
    nn30 = 'RSS link location'
    nn31 = 'Text filter'
    nn32 = 'Use SmartyPants?'
    nn33 = 'Use custom field 1?'
    nn34 = 'Use custom field 2?'
    nn35 = 'Use custom field 3?'
    nn36 = 'Custom field 1'
    nn37 = 'Custom field 2'
    nn38 = 'Custom field 3'
    nn39 = 'Extended link text'
    nn40 = 'Use simple titles?'
    nn41 = 'Theme'
    
    # descriptions
    ds1  = "Your site's domain, do not include http://"
    ds2  = "Your site's name."
    ds3  = "Your site's slogan, shown in the title of the index page."
    ds4  = "Used in the meta description tag."
    ds5  = "Your name."
    ds6  = "What is your gender? Useful for proper he/shes later."
    ds7  = "Your email address."
    ds8  = "Contact emails sent through the default link will have this subject."
    ds9  = "Title of error page when we hit a 404."
    ds10 = "Number of items to return in quicksearch results."
    ds11 = "Number of posts to show on the index page."
    ds12 = "Number of posts to show in the RSS feed."
    ds13 = "What time is it where you are?"
    ds14 = "Want to turn -- into an em dash (&mdash;)?"
    ds15 = "Want to warn users of bad browsers?"
    ds16 = "Show the name of the author who wrote each post?"
    ds17 = "Auto-check the \"ping\" box when creating a new post?"
    ds18 = "Show post preview in admin section by default?"
    ds19 = "Go directly to new post form when entering admin section?"
    ds20 = 'Time format used in views (see <a href="http://www.ruby-doc.org/core/classes/Time.html#M000258" title="rubydoc" target="_blank">rubydoc</a>).'
    ds21 = 'Date format used in views (see <a href="http://www.ruby-doc.org/core/classes/Time.html#M000258" title="rubydoc" target="_blank">rubydoc</a>).'
    ds22 = "First year this site was under your copyright."
    ds23 = 'Your <a href="http://geourl.org" title="GeoURL" target="blank">GeoURL</a> ICBM address, if you have one.'
    ds24 = 'Your <a href="http://issn.org" title="ISSN" target="blank">ISSN</a>, if you have one.'
    ds25 = 'Your <a href="http://numly.com" title="ESBN" target="blank">ESBN</a>, if you have one.'
    ds26 = "Site encoding (if you're unsure, leave this as-is)."
    ds27 = 'See <a href="http://www.loc.gov/standards/iso639-2/langcodes.html" title="Langauge codes" target="_blank">the list of available codes</a> (can be mutliple, separated with commas).'
    ds28 = 'The directory you installed <a href="http://haveamint.com" title="Mint" target="_blank">Mint</a> into, if you have (no leading/trailing slashes necessary).'
    ds29 = 'Your <a href="http://del.icio.us" title="del.icio.us" target="_blank">del.icio.us</a> username, if you have one.'
    ds30 = 'Do not include http:// (<a href="/admin/help#hq9" title="Help: What does the &quot;RSS link location&quot; preference do?&quot;" target="_blank">see help</a> for details).'
    ds31 = 'Choose between <a href="http://daringfireball.net/projects/markdown" title="Markdown" target="_blank">Markdown</a> or <a href="http://www.textism.com/tools/textile" title="Textile" target="_blank">Textile</a> to simplify your writing experience.'
    ds32 = 'Changes quotes into curly quotes, three dots into ellipses, et cetera</span></label><label class="left" for=""><span class="small gray"> (<a href="http://daringfireball.net/projects/smartypants" title="SmartyPants" target="_blank">details</a>).'
    ds33 = 'Enable this field'
    ds34 = ds33
    ds35 = ds33
    ds36 = ' (<a href="/admin/help#hq10" title="Help: What do the &quot;Custom field&quot; preferences do?&quot;" target="_blank">see help</a> for details).&nbsp;&nbsp;Name:&nbsp;'
    ds37 = ds36
    ds38 = ds36
    ds39 = 'Link text to use when entry has extended content.'
    ds40 = 'Use the first five words of your post as its title on the site</span></label><label class="left" for=""><span class="small gray"> (<a href="/admin/help#hq11" title="Help: What does the &quot;Use simple titles&quot; preference do?" target="_blank">details</a>)?'
    ds41 = 'Choose from your currently installed themes.'

    # okay, now let's use them and set things up
    
    if upgrade
    # let's get information from the previous site.rb file
    
      Preference.new(:nice_name => nn1, :description => ds1, :name => 'domain', :value => ENV['DOMAIN']).save
      Preference.new(:nice_name => nn2, :description => ds2, :name => 'site_name', :value => ENV['SITE_NAME']).save
      Preference.new(:nice_name => nn3, :description => ds3, :name => 'slogan', :value => ENV['SLOGAN']).save
      Preference.new(:nice_name => nn4, :description => ds4, :name => 'site_description', :value => ENV['SITE_DESCRIPTION']).save
      Preference.new(:nice_name => nn5, :description => ds5, :name => 'site_primary_author', :value => ENV['SITE_PRIMARY_AUTHOR']).save
      Preference.new(:nice_name => nn6, :description => ds6, :name => 'author_gender', :value => ENV['AUTHOR_GENDER']).save
      Preference.new(:nice_name => nn7, :description => ds7, :name => 'author_email', :value => ENV['AUTHOR_EMAIL']).save
      Preference.new(:nice_name => nn8, :description => ds8, :name => 'email_subject', :value => ENV['EMAIL_SUBJECT']).save
      Preference.new(:nice_name => nn9, :description => ds9, :name => 'error_page_title', :value => ENV['ERROR_PAGE_TITLE']).save
      Preference.new(:nice_name => nn10, :description => ds10, :name => 'search_results', :value => ENV['SEARCH_RESULTS']).save
      Preference.new(:nice_name => nn11, :description => ds11, :name => 'items_on_index', :value => ENV['ITEMS_ON_INDEX']).save
      Preference.new(:nice_name => nn12, :description => ds12, :name => 'items_in_feed', :value => ENV['ITEMS_IN_FEED']).save
      Preference.new(:nice_name => nn13, :description => ds13, :name => 'offset', :value => '0').save
      Preference.new(:nice_name => nn14, :description => ds14, :name => 'nice_dashes', :value => ENV['NICE_DASHES']).save
      Preference.new(:nice_name => nn15, :description => ds15, :name => 'warn_bad_browsers', :value => ENV['WARN_BAD_BROWSERS']).save
      Preference.new(:nice_name => nn16, :description => ds16, :name => 'show_author_of_post', :value => ENV['SHOW_AUTHOR_OF_POST']).save
      Preference.new(:nice_name => nn17, :description => ds17, :name => 'ping_by_default', :value => ENV['PING_BY_DEFAULT']).save
      Preference.new(:nice_name => nn18, :description => ds18, :name => 'preview_by_default', :value => ENV['PREVIEW_BY_DEFAULT']).save
      Preference.new(:nice_name => nn19, :description => ds19, :name => 'new_post_by_default', :value => ENV['NEW_POST_BY_DEFAULT']).save
      Preference.new(:nice_name => nn20, :description => ds20, :name => 'time_format', :value => ENV['TIME_FORMAT']).save
      Preference.new(:nice_name => nn21, :description => ds21, :name => 'date_format', :value => ENV['DATE_FORMAT']).save
      Preference.new(:nice_name => nn22, :description => ds22, :name => 'copyright_year', :value => ENV['COPYRIGHT_YEAR']).save
      Preference.new(:nice_name => nn23, :description => ds23, :name => 'icbm', :value => ENV['ICBM']).save
      Preference.new(:nice_name => nn24, :description => ds24, :name => 'issn', :value => ENV['ISSN']).save
      Preference.new(:nice_name => nn25, :description => ds25, :name => 'esbn', :value => ENV['ESBN']).save
      Preference.new(:nice_name => nn26, :description => ds26, :name => 'encoding', :value => ENV['ENCODING']).save
      Preference.new(:nice_name => nn27, :description => ds27, :name => 'language', :value => ENV['LANGUAGE']).save
      Preference.new(:nice_name => nn28, :description => ds28, :name => 'mint_dir', :value => ENV['MINT_DIR']).save
      Preference.new(:nice_name => nn29, :description => ds29, :name => 'delicious_username', :value => ENV['DELICIOUS_USERNAME']).save
      Preference.new(:nice_name => nn30, :description => ds30, :name => 'rss_url', :value => ENV['RSS_URL']).save
      Preference.new(:nice_name => nn31, :description => ds31, :name => 'text_filter', :value => ENV['TEXT_FILTER']).save
      Preference.new(:nice_name => nn32, :description => ds32, :name => 'smarty_pants', :value => 'no').save
      Preference.new(:nice_name => nn33, :description => ds33, :name => 'custom_field_1_on', :value => 'no').save
      Preference.new(:nice_name => nn34, :description => ds34, :name => 'custom_field_2_on', :value => 'no').save
      Preference.new(:nice_name => nn35, :description => ds35, :name => 'custom_field_3_on', :value => 'no').save
      Preference.new(:nice_name => nn36, :description => ds36, :name => 'custom_field_1', :value => '').save
      Preference.new(:nice_name => nn37, :description => ds37, :name => 'custom_field_2', :value => '').save
      Preference.new(:nice_name => nn38, :description => ds38, :name => 'custom_field_3', :value => '').save
      Preference.new(:nice_name => nn39, :description => ds39, :name => 'extended_link_text', :value => 'Post continues, click to read more...').save
      Preference.new(:nice_name => nn40, :description => ds40, :name => 'simple_titles', :value => 'no').save
      Preference.new(:nice_name => nn41, :description => ds41, :name => 'current_theme', :value => 'simplelog').save
     
    else
    # let's create default information
    
      Preference.new(:nice_name => nn1, :description => ds1, :name => 'domain', :value => '').save
      Preference.new(:nice_name => nn2, :description => ds2, :name => 'site_name', :value => 'My Amazing Weblog').save
      Preference.new(:nice_name => nn3, :description => ds3, :name => 'slogan', :value => 'My writing is gold!').save
      Preference.new(:nice_name => nn4, :description => ds4, :name => 'site_description', :value => 'The weblog of Someone.').save
      Preference.new(:nice_name => nn5, :description => ds5, :name => 'site_primary_author', :value => 'Someone').save
      Preference.new(:nice_name => nn6, :description => ds6, :name => 'author_gender', :value => 'male').save
      Preference.new(:nice_name => nn7, :description => ds7, :name => 'author_email', :value => 'me@someone.com').save
      Preference.new(:nice_name => nn8, :description => ds8, :name => 'email_subject', :value => 'About your site').save
      Preference.new(:nice_name => nn9, :description => ds9, :name => 'error_page_title', :value => '404').save
      Preference.new(:nice_name => nn10, :description => ds10, :name => 'search_results', :value => '20').save
      Preference.new(:nice_name => nn11, :description => ds11, :name => 'items_on_index', :value => '5').save
      Preference.new(:nice_name => nn12, :description => ds12, :name => 'items_in_feed', :value => '10').save
      Preference.new(:nice_name => nn13, :description => ds13, :name => 'offset', :value => '0').save
      Preference.new(:nice_name => nn14, :description => ds14, :name => 'nice_dashes', :value => 'yes').save
      Preference.new(:nice_name => nn15, :description => ds15, :name => 'warn_bad_browsers', :value => 'no').save
      Preference.new(:nice_name => nn16, :description => ds16, :name => 'show_author_of_post', :value => 'yes').save
      Preference.new(:nice_name => nn17, :description => ds17, :name => 'ping_by_default', :value => 'yes').save
      Preference.new(:nice_name => nn18, :description => ds18, :name => 'preview_by_default', :value => 'yes').save
      Preference.new(:nice_name => nn19, :description => ds19, :name => 'new_post_by_default', :value => 'no').save
      Preference.new(:nice_name => nn20, :description => ds20, :name => 'time_format', :value => '%I:%M %p').save
      Preference.new(:nice_name => nn21, :description => ds21, :name => 'date_format', :value => '%B %d, %Y').save
      Preference.new(:nice_name => nn22, :description => ds22, :name => 'copyright_year', :value => '2007').save
      Preference.new(:nice_name => nn23, :description => ds23, :name => 'icbm', :value => '').save
      Preference.new(:nice_name => nn24, :description => ds24, :name => 'issn', :value => '').save
      Preference.new(:nice_name => nn25, :description => ds25, :name => 'esbn', :value => '').save
      Preference.new(:nice_name => nn26, :description => ds26, :name => 'encoding', :value => 'utf-8').save
      Preference.new(:nice_name => nn27, :description => ds27, :name => 'language', :value => 'en').save
      Preference.new(:nice_name => nn28, :description => ds28, :name => 'mint_dir', :value => '').save
      Preference.new(:nice_name => nn29, :description => ds29, :name => 'delicious_username', :value => '').save
      Preference.new(:nice_name => nn30, :description => ds30, :name => 'rss_url', :value => '').save
      Preference.new(:nice_name => nn31, :description => ds31, :name => 'text_filter', :value => 'markdown').save
      Preference.new(:nice_name => nn32, :description => ds32, :name => 'smarty_pants', :value => 'no').save
      Preference.new(:nice_name => nn33, :description => ds33, :name => 'custom_field_1_on', :value => 'no').save
      Preference.new(:nice_name => nn34, :description => ds34, :name => 'custom_field_2_on', :value => 'no').save
      Preference.new(:nice_name => nn35, :description => ds35, :name => 'custom_field_3_on', :value => 'no').save
      Preference.new(:nice_name => nn36, :description => ds36, :name => 'custom_field_1', :value => '').save
      Preference.new(:nice_name => nn37, :description => ds37, :name => 'custom_field_2', :value => '').save
      Preference.new(:nice_name => nn38, :description => ds38, :name => 'custom_field_3', :value => '').save
      Preference.new(:nice_name => nn39, :description => ds39, :name => 'extended_link_text', :value => 'Post continues, click to read more...').save
      Preference.new(:nice_name => nn40, :description => ds40, :name => 'simple_titles', :value => 'no').save
      Preference.new(:nice_name => nn41, :description => ds41, :name => 'current_theme', :value => 'simplelog').save
 
    end
    
    # adding some (potentially) useful custom fields to the posts table
    add_column "posts", "custom_field_1", :string
    add_column "posts", "custom_field_2", :string
    add_column "posts", "custom_field_3", :string
    
  end

  def self.down
    drop_table "preferences"
    remove_column "posts", "custom_field_1"
    remove_column "posts", "custom_field_2"
    remove_column "posts", "custom_field_3"
  end
end