# $Id: blacklist_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::BlacklistController < Admin::BaseController
  
  #
  # the blacklist keeps the spam out, or tries to
  #
  
  # get a list of blacklist items, paginated, with sorting
	def blacklist_list
	  # grab the items
	  @items = (Blacklist.cache.length > 0 ? Blacklist.cache : Blacklist.find(:all, :order => 'item asc'))
	  render :template => 'admin/blacklist/blacklist_list'
  end
  
  # update the blacklist with a big block of text
  def blacklist_update
    # delete the current records first
    Blacklist.delete_all
    # clear the cache
    Blacklist.clear_cache
    # grab the time
    the_time = Time.sl_local.strftime('%Y-%m-%d %H:%M:%S')
    
    # build a list of new items
    if params[:full_blacklist] != ''
      # split the list
      all_items = params[:full_blacklist].split(/\n/)
      # let's keep track of what we have added to avoid dups
      items_added = Array.new
      # for building the SQL
      sql = ''
      for i in all_items
        # strip whitespace
        i.strip!
        # skip this if it's a blank line
        next if i == ''
        # check to make sure we haven't already added this
        if !items_added.index(i)
          sql = "INSERT INTO blacklist (item, created_at) VALUES ('#{i.gsub(/\\/, '\&\&').gsub(/'/, "''")}', '#{the_time}')"
          ActiveRecord::Base.connection.execute(sql)
          # store this in a cache
          Blacklist.add_to_cache(Blacklist.new(:item => i))
        end
        # keep track of what we've added
        items_added << i
      end
      # clear this memory
      items_added = nil
    end
    flash[:notice] = '<b>Success</b>: Blacklist updated.'
    redirect_to Site.full_url + '/admin/blacklist'
  end
  
  # add a blacklist item remotely (from comments section), using text
  def blacklist_add_remote
    if params[:item] and params[:item] != ''
      i = Blacklist.new(:item => params[:item], :created_at => Time.sl_local)
      i.save
      # add this to the cache if it exists
      Blacklist.add_to_cache(i) if Blacklist.cache.length > 0
    end
    render :nothing => true
  end
  
  # destroy a blacklist item remotely (from comments section), using text
  def blacklist_destroy_remote
    if params[:item] and params[:item] != ''
      i = Blacklist.find(:first, :conditions => ['item = ?', params[:item]])
      i.destroy if i
      # remove this from the cache if it exists
      Blacklist.delete_from_cache(i) if Blacklist.cache.length > 0
    end
    render :nothing => true
  end
  
  # get rules from the simplelog.net clearinghouse
  def blacklist_get_remote
    # grab the updates xml file
	  remote_list = Net::HTTP.get(URI.parse('http://' + SL_CONFIG[:BLACKLIST_URL])) rescue ''
	  # check the server's response code
	  server_response = Net::HTTP.get_response(URI.parse('http://' + SL_CONFIG[:BLACKLIST_URL])).value rescue 0
	  if remote_list == '' or server_response == 0
	  # couldn't get update info from the server--return error msg if necessary
	    #render :nothing => true
	    render :nothing => true
	    return false
    end
	  # break it in two
	  render :text => remote_list
	  return true
	rescue
	# an error of some sort, return error or false
	  render :nothing => true
    return false
  end
  
end