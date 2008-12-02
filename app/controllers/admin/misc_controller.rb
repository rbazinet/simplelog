# $Id: misc_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::MiscController < Admin::BaseController
  
  #
  # pinging, update checking and help... ah, miscellany
  #
  
  #
	# ping
	#
	
  # just set the title
  def ping
    $admin_page_title = 'Ping'
    @onload = "document.forms['ping_form'].elements['pbutton'].focus()"
    render :template => 'admin/misc/ping'
  end
  
	# use pingomatic to ping common services
	def do_ping
	  # open the XMLRPC server connection
	  server = XMLRPC::Client.new('rpc.pingomatic.com', '/')
	  # do the ping
	  ping = server.call('weblogUpdates.extendedPing', Preference.get_setting('SITE_NAME'), 'http://' + Preference.get_setting('DOMAIN'), 'http://' + (Preference.get_setting('RSS_URL') != '' ? Preference.get_setting('RSS_URL') : Preference.get_setting('DOMAIN')))
	  render :nothing => true
	rescue
	  render :text => 'Error!'
  end
  
  #
  # check for updates
  #
  
  # just set the title
  def updates
    $admin_page_title = 'Updates'
    @onload = "document.forms['update_form'].elements['ubutton'].focus()"
    render :template => 'admin/misc/updates'
  end
  
	# check the simplelog.net server for updates
	def do_update_check(render_msg = true)
	  # grab the updates xml file
	  server_version_info = Net::HTTP.get(URI.parse('http://' + SL_CONFIG[:UPDATES_URL])) rescue ''
	  # check the server's response code
	  server_response = Net::HTTP.get_response(URI.parse('http://' + SL_CONFIG[:UPDATES_URL])).value rescue 0
	  if server_version_info == '' or server_response == 0
	  # couldn't get update info from the server--return error msg if necessary
	    if render_msg
	      render :text => '<p><b>Error:</b> Couldn\'t reach server. Please try again later.</p>'
	      return
	    else
	      return false
      end
    end
	  # break it in two
	  server_version_info = server_version_info.split("\n")
	  # get the version number
	  server_version = server_version_info[0].gsub(/\<(\/*)version\>/, '').strip
	  if server_version != '' and server_version != SL_CONFIG[:VERSION]
	  # different version on server
	    output = "<p><b>Update found!</b> Version #{server_version} is now available: <a href=\"http://simplelog.net\" title=\"Visit the SimpleLog website\" target=\"_blank\">Visit the SimpleLog website</a> to download.</p>"
	    # grab the change details
  	  version_details = server_version_info[1].gsub(/\<(\/*)changes\>/, '').strip.split('|')
	    output += '<p><b>Changes in this version:</b></p>'
	    output += '<ul>'
  	  for d in version_details
  	  # write out the change details
  	    output += "<li>#{d}</li>"
	    end
	    output += '</ul>'
      update_checker_info(true, server_version)
	  else
	  # no new version available
      output = "<p><b>Hooray!</b> You're running the newest version of SimpleLog.</p>"
      update_checker_info(false)
    end
    # let's return our output now, if necessary
	  if render_msg
	    render :text => output
	    return
	  else
	    return true
    end
	rescue
	# an error of some sort, return error or false
	  if render_msg
	    render :text => 'Error!'
	    return
	  else
	    return false
    end
  end
  
  # turn auto updates on and off via the updates section (this is also a pref in prefs)
  def toggle_updates_check
    current = Preference.get_setting('check_for_updates')
    Preference.set_setting('check_for_updates', (current == 'yes' ? 'no' : 'yes'))
    # clear the stored session
	  session[:update_check_stored] = nil
    # clear the theme cache
    FileUtils.rm_r "#{RAILS_ROOT}/public/themes", :force => true
    # unset the theme
    @@gm_curr_theme = nil
    # unset prefs hash
    Preference.clear_hash
    if session[:came_from]
		# they came from somewhere, let's send them back there
			temp = session[:came_from]
			session[:came_from] = nil
			redirect_to :back
		else
		# not sure where they came from, just send them to Site.full_url + /admin/updates
			redirect_to Site.full_url + '/admin/updates'
		end
  end
  
  # updates the update checker info
  def update_checker_info(available, version = nil, time = Time.sl_local)
    update_checker = Update.find(1)
    update_checker.last_checked_at = time
    update_checker.update_available = available
    update_checker.update_version = version if version
    update_checker.save
  end
  
  #
  # help
  #
  
  # just set the title
  def help
    $admin_page_title = 'Help'
    render :template => 'admin/misc/help'
  end
  
end