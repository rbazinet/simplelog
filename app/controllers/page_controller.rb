# $Id: page_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class PageController < ApplicationController
  
  #
  # the page controller handles "static" pages
  #
  
  # use the post layout
  layout 'site'
  theme :get_theme
  
  # grab the site helper for prefs and such (thanks garrett dimon for this idea!)
  helper :site
  
  # default page title (set in prefs)
  $page_title = Preference.get_setting('SLOGAN')
  
  # we need a list of tags on every page this controller will serve, so let's
  # just go ahead and get them automatically every time
  before_filter :pre_page
  def pre_page
    # get all the tags in use
    @tags = Post.get_tags
    if Preference.get_setting('SHOW_AUTHOR_OF_POST') == 'yes'
      @authors_list = Author.get_all
    end
  end
  
  # show a page based on its permalink (/pages/:permalink)
  def show
    @page = Page.find_by_link(params[:link])
    if !@page
    # page doesn't exist, send them packin'
      redirect_to Site.full_url + '/notfound'
      return
    end
    # set the page title
    $page_title = @page.title + '.'
    render :template => 'pages/show'
  end
  
end