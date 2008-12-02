# $Id: base_controller.rb 327 2007-02-08 22:49:53Z garrett $

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

# used for xmlrpc services
require 'xmlrpc/client'

class Admin::BaseController < ApplicationController
  
  #
  # the admin controllers handle all the CRUD functionality for content on the site
  # see all the other subclasses for functionality, the base controller wraps
  # everything in security and shares some common functions
  #
  
  # only authorized people should see this stuff, and we should use the admin layout
  before_filter :user_authorize
  # run the auto update checker, unless we're in a process action as listed
  before_filter :update_checker, :except => [
                                            :post_create, :post_update, :post_destroy,
                                            :check_for_bad_xhtml, :post_preview, :tag_create,
                                            :tag_update, :tag_destroy, :author_create,
                                            :author_update, :author_destroy, :toggle_updates_check,
                                            :do_update_check, :do_ping, :prefs_save
                                            ]
  layout 'admin'
  theme nil
  
  # grab the site helper for prefs and such (thanks garrett dimon for this idea!)
  helper :site
  
  # default page title
  $admin_page_title = 'Administration'
  
  # a list of actions on which we shouldn't create a came_from session
  # since users shouldn't be forwarded back to these actions since they store data mostly
  $no_session_actions = [
                        'blacklist_update', 'blacklist_get_remote',
                        'post_create', 'post_update', 'post_preview',
                        'page_create', 'page_update', 'page_preview',
                        'comment_update', 'comment_preview',
                        'tag_create', 'tag_update',
                        'author_create', 'author_update',
                        'prefs_save'
                        ]
  
  # uses the author class' authorize method and checks for a valid user
  def user_authorize
    valid = Author.authorize(cookies[SL_CONFIG[:USER_EMAIL_COOKIE]], cookies[SL_CONFIG[:USER_HASH_COOKIE]])
    unless valid
      # we didn't find a author... send them to the login page
      session[:came_from] = nil
      session[:came_from] = request.parameters if !$no_session_actions.index(params[:action])
      flash[:notice] = 'Please log in'
      redirect_to Site.full_url + '/login' and return false
    end
  end
	
	# checks for updates if auto updates is turned on
	def update_checker
	  if Preference.get_setting('CHECK_FOR_UPDATES') == 'yes'
	    # grab the misc class for use here
	    misc_class = Admin::MiscController.new
	    # track where they came from, in case they turn this off
      session[:came_from] = nil
	    session[:came_from] = request.parameters if !$no_session_actions.index(params[:action])
	    # get the last update record
	    last_update = Update.find(1)
	    # how long ago was this check?
	    difference = ((((Time.sl_local.to_i-last_update.last_checked_at.to_i)/60)/60)/24)
	    if difference > 5
	    # there hasn't been a check in over 5 days, let's check now
	      # run the check
	      worked = true
	      worked = misc_class.do_update_check(false)
	      # run this method again now
	      update_checker if worked
	      # we're done
	      return
      else
      # there was a check relatively recently, was there an update available?
        if last_update.update_available
        # there was!
          if last_update.update_version != SL_CONFIG[:VERSION]
          # this is a different version, let's tell them about it
            @update_checker = "<b>Update found!</b> Version #{last_update.update_version} is <a href=\"http://simplelog.net\" title=\"Visit the SimpleLog website\" target=\"_blank\">now available</a>. (Want to <a href=\"#{Site.full_url}/admin/updates/auto/toggle\" title=\"Turn off auto update checking\">turn off auto update checking</a>?)"
            session[:update_check_version_stored] = last_update.update_version
            session[:update_check_stored] = @update_checker
          else
          # we already have this version installed, let's update the update checker
            misc_class.update_checker_info(false, last_update.update_version, last_update.last_checked_at)
            session[:update_check_version_stored] = nil
            session[:update_check_stored] = nil
            return
          end
        else
        # there wasn't, we're done
          session[:update_check_version_stored] = nil
          session[:update_check_stored] = nil
          return
        end
      end
    end
  end
	
	# checks content for malformed XHTML
	def check_for_bad_xhtml(input, content_label = 'post', text_filter = Preference.get_setting('TEXT_FILTER'))
	  return Post.create_clean_content(input, text_filter) rescue "<p>You have malformed XHTML code in your #{content_label}...</p>"
  end
	
	# depending on preference, we send user to a new post form, or to the posts list
	def index
	  if Preference.get_setting('NEW_POST_BY_DEFAULT') == 'yes'
	    redirect_to Site.full_url + '/admin/posts/new'
    else
      redirect_to Site.full_url + '/admin/posts'
    end
	end
	  
end