# $Id: prefs_controller.rb 300 2007-02-01 23:01:00Z garrett $

#--
# Copyright (C) 2006-2007 Garrett Murray
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program (doc/LICENSE); if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301 USA.
#++

class Admin::PrefsController < Admin::BaseController
  
  #
  # i guess people should be able to specify their preferences, eh?
  #
  
  # monitor prefs errors for use later
	def record_pref_err(nice_name = '', name = '', error = '')
    return Hash['nice_name' => nice_name, 'name' => name, 'error' => error]
  end
  
  # remove the http:// from URLs if necessary
  def strip_http(url = '')
		return url.gsub('http://', '')
  end
  
	# get prefs list
  def prefs_list
    # clear the sessions table
    sql = "DELETE FROM sessions"
    ActiveRecord::Base.connection.execute(sql)
    # grab ALL the prefs
    prefs = Preference.find(:all)
    # we'll use this hash in the form
    @prefs_hash = Hash.new()
    # loop through prefs
    for p in prefs
      # create actual hash of data
      prefs_sub_hash = Hash.new()
      prefs_sub_hash['nice_name']   = p.nice_name
      prefs_sub_hash['description'] = p.description
      prefs_sub_hash['value']       = p.value
      # add it to the main hash by name key
      @prefs_hash[p.name]           = prefs_sub_hash 
    end
    $admin_page_title = 'Preferences'
    if session[:was_on_tab]
    # they were on a tab, let's switch to it
      @onload = "swapTab('#{session[:was_on_tab]}')"
      session[:was_on_tab] = nil
    else
      @onload = "document.forms['prefs_form'].elements['preferences[domain]'].focus()"
    end
    render :template => 'admin/prefs/prefs_list'
  end

  # save preferences
	def prefs_save
	  # worry about errors here, assume we have none to start
	  @write_errors = false
	  # blank array to store them
	  @errors_list = []
	  if !params[:preferences]['domain'] or params[:preferences]['domain'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Domain', 'domain', 'cannot be blank. [<a href="#" onclick="swapTab(\'site_details\')" title="Show the Site Details tab">Site details</a>]')
    end
	  if !params[:preferences]['site_name'] or params[:preferences]['site_name'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Site name', 'site_name', 'cannot be blank. [<a href="#" onclick="swapTab(\'site_details\')" title="Show the Site Details tab">Site details</a>]')
    end
    if !params[:preferences]['site_primary_author'] or params[:preferences]['site_primary_author'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Site owner', 'site_primary_author', 'cannot be blank. [<a href="#" onclick="swapTab(\'site_details\')" title="Show the Site Details tab">Site details</a>]')
    end
    if !params[:preferences]['author_email'] or params[:preferences]['author_email'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Owner email', 'author_email', 'cannot be blank. [<a href="#" onclick="swapTab(\'site_details\')" title="Show the Site Details tab">Site details</a>]')
    end
    if !params[:preferences]['items_on_index'] or params[:preferences]['items_on_index'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items on index', 'items_on_index', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    elsif params[:preferences]['items_on_index'].gsub(/[^0-9]/, '') == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items on index', 'items_on_index', 'must be a number. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['items_in_feed'] or params[:preferences]['items_in_feed'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in feed', 'items_in_feed', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    elsif params[:preferences]['items_in_feed'].gsub(/[^0-9]/, '') == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in feed', 'items_in_feed', 'must be a number. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['search_results'] or params[:preferences]['search_results'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in quicksearch', 'search_results', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    elsif params[:preferences]['search_results'].gsub(/[^0-9]/, '') == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in quicksearch', 'search_results', 'must be a number. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['search_results_full'] or params[:preferences]['search_results_full'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in full seach', 'search_results_full', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    elsif params[:preferences]['search_results_full'].gsub(/[^0-9]/, '') == ''
	    @errors_list[@errors_list.length] = record_pref_err('Items in full search', 'search_results_full', 'must be a number. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['time_format'] or params[:preferences]['time_format'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Time format', 'time_format', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['date_format'] or params[:preferences]['date_format'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Date format', 'date_format', 'cannot be blank. [<a href="#" onclick="swapTab(\'display_settings\')" title="Show the Display tab">Display</a>]')
    end
    if !params[:preferences]['language'] or params[:preferences]['language'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Language', 'language', 'cannot be blank. [<a href="#" onclick="swapTab(\'advanced_settings\')" title="Show the Advanced tab">Advanced</a>]')
    end
    if !params[:preferences]['extended_link_text'] or params[:preferences]['extended_link_text'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Extended link text', 'extended_link_text', 'cannot be blank. [<a href="#" onclick="swapTab(\'content_settings\')" title="Show the Content tab">Content</a>]')
    end
    if !params[:preferences]['copyright_year'] or params[:preferences]['copyright_year'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Copyright year', 'copyright_year', 'cannot be blank. [<a href="#" onclick="swapTab(\'meta_information\')" title="Show the Meta Info tab">Meta Info</a>]')
    end
    if !params[:preferences]['email_subject'] or params[:preferences]['email_subject'] == ''
	    @errors_list[@errors_list.length] = record_pref_err('Email subject', 'email_subject', 'cannot be blank. [<a href="#" onclick="swapTab(\'meta_information\')" title="Show the Meta Info tab">Meta Info</a>]')
    end
    # check if we have any
    @write_errors = true if @errors_list.length > 0
	  
	  # we'll check for errors
	  errors = false
	  # loop through the preferences
	  params[:preferences].each do |key, value|
	    if key == 'search_results' or key == 'items_on_index' or key == 'items_in_feed'
	    # make sure some values are non-negative numbers
	      value = value.to_i.abs.to_s
      end
      if key == 'domain' or key == 'rss_url'
        value = strip_http(value)
      end
      if key == 'domain'
        value = (value[-1, 1] == '/' ? value[0, value.length-1] : value)
      end
	    # find them in the db
	    pref = Preference.find(:first, :conditions => ['name = ?', key])
	    if pref
	    # found it, save it
	      pref.value = value
	      if !pref.save
	      # there was an error
          errors = true
    		end
      end
    end
    
    # clear the theme cache
    FileUtils.rm_r "#{RAILS_ROOT}/public/themes", :force => true
    # unset the theme
    @@gm_curr_theme = nil
    # unset prefs hash
    Preference.clear_hash
    
    if @write_errors
    # if we have errors, let's show the list again with pretty Rails-style error message
      prefs_list
      return
    else
      # remember which tab they were on
      session[:was_on_tab] = params[:current_tab]
      if !errors
      # preferences saved successfully
    		flash[:notice] = '<b>Success:</b> Preferences were saved.'
    		redirect_to Site.full_url + '/admin/prefs'
      else
      # we had ACTUAL errors, as in we couldn't save data for some reason
        flash[:notice] = '<span class="red"><b>Failed:</b> Some of your preferences could not be saved. Please try again.</span>'
        redirect_to Site.full_url + '/admin/prefs'
      end
    end
	end
  
  # clear the theme cache from a link
  def prefs_clear_cache
    # clear the theme cache
    FileUtils.rm_r "#{RAILS_ROOT}/public/themes", :force => true
    # unset the theme
    @@gm_curr_theme = nil
    # unset prefs hash
    Preference.clear_hash
    # that's it!
    flash[:notice] = '<b>Success:</b> Theme cache was cleared.'
    # redirect back
    redirect_to Site.full_url + '/admin/prefs'
  end
  
end