# $Id: author_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class AuthorController < ApplicationController
  
  #
  # the author controller handles login/logout for the admin section. it doesn't
  # need to do anything else because authors are created and managed in the admin
  # section, which is handled by the admin controller.
  #
  
  # let's use the post layout for this, except when we're actually doing the login action
  layout 'admin_login', :except => 'do_login'
  
  # grab the site helper for prefs and such (thanks garrett dimon for this idea!)
  helper :site
  
  # login page creates a new author for login purposes
  def login
    # when we log in, we're looking at a page that looks like all other pages,
    # so we need some data for the layout
    @tags = Post.tag_count
    # create a new author to access
    @author = Author.new
    # set the page title
    $page_title = 'Log in.'
    render :template => 'admin/login/login'
  end
  
  # login form is submitted, we need to check it
  def do_login
    login_error = false # for error checking
    @author = Author.new(params[:author])
    if @author.email != '' && @author.password != ''
    # the author entered the required data, let's check it
      @logged_in_author = Author.find(:all, :conditions => ['email = ? and hashed_pass = ? and is_active = true', @author.email, Author.do_password_hash(@author.password)])
      if @logged_in_author.length > 0
      # we found a author, let's set cookies and send them on their way
				cookies[SL_CONFIG[:USER_EMAIL_COOKIE]] = { :value => @logged_in_author[0].email, :expires => Time.now + 31536000 }
				cookies[SL_CONFIG[:USER_HASH_COOKIE]] = { :value => @logged_in_author[0].hashed_pass, :expires => Time.now + 31536000 }
				if session[:came_from]
				# they came from somewhere, let's send them back there
					temp = session[:came_from]
					session[:came_from] = nil
					redirect_to temp
				else
				# not sure where they came from, just send them to /admin
					redirect_to Site.full_url + '/admin'
				end
			else
			# no good
				flash[:notice] = 'Sorry, but that email/password combination is invalid.'
				login_error = true
			end
  	else
  	# didn't enter required data
  		flash[:notice] = 'You must enter an email and a password.'
  		login_error = true
  	end
  	if login_error
  	# there was an error--delete the cookies and send them back to the login page
  	  cookies.delete SL_CONFIG[:USER_EMAIL_COOKIE]
			cookies.delete SL_CONFIG[:USER_HASH_COOKIE]
			redirect_to Site.full_url + '/login'
  	end
  end
  
  # logs a author out by destroying cookies
  def logout
    cookies.delete SL_CONFIG[:USER_EMAIL_COOKIE]
		cookies.delete SL_CONFIG[:USER_HASH_COOKIE]
		redirect_to Site.full_url
  end
  
end