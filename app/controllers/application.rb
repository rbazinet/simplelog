# $Id: application.rb 329 2007-02-09 19:39:12Z garrett $

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

# used to get preferences site-wide
require 'preference'

class ApplicationController < ActionController::Base
  
  #
  # i <3 you, application controller. you do all the stuff that needs to be
  # done on the application layer (which isn't much in this case).
  #
  
  # nearly everything should use the post layout, except the admin section (which we'll deal with later)
  layout 'site'
  theme :get_theme
  
  # grab the site helper for prefs and such (thanks garrett dimon for this idea!)
  helper :site
  
  # we need to make sure the Site class has the application params on each load
  before_filter :load_params_and_req
  def load_params_and_req
    # send params to the Site class
    Site.get_params_and_req(params, request)
  end
  
  # gets the current theme or returns default if it comes back blank
  def get_theme
    use_theme = Preference.get_setting('CURRENT_THEME')
    (use_theme == '' ? 'default' : use_theme).downcase
  end
  
  # in the case of an http error
  def handle_unknown_request
    $params = request.request_uri # the requested URI
    # we're still going to build the 'about' block, so let's get that data
    @posts = Post.find_current
    @tags = Post.tags_count(:count => '> 0', :current_only => true, :order => 'name asc')
    $page_title = Preference.get_setting('ERROR_PAGE_TITLE')
    @error = true # for use later
    render :template => 'errors/unknown_request'
  end
  
end


class Time #:nodoc:
  
  # extends Time to add a simplelog localtime object which uses preference-set
  # offset and the current server time to get the accurate user's time
  def self.sl_local
    return (Time.now+(Preference.get_setting('OFFSET').to_i*60*60)).getgm
  end
  
  # localize a timestamp to simplelog localtime
  def self.sl_localize(t)
    return (t+(Preference.get_setting('OFFSET').to_i*60*60)).getgm
  end
  
  # localized time in DB format
  def self.sl_local_db
    return Time.sl_local.strftime('%Y-%m-%d %H:%M%:S')
  end
  
end