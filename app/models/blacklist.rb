# $Id: blacklist.rb 300 2007-02-01 23:01:00Z garrett $

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

class Blacklist < ActiveRecord::Base
  
  #
  # useful for blocking different types of comments
  #
  
  # table name (no plural here)
  set_table_name 'blacklist'
  
  # validations
  validates_presence_of :item
  
  # before we create, let's set the creation date
  def before_create
    # set the time
	  self.created_at = Time.sl_local
  end
  
  # returns the cache
  def self.cache
    return @@stored_blacklist
  end
  
  # add an item to the cached array
  def self.add_to_cache(item)
    @@stored_blacklist << item
  end
  
  # remove an item from the cached array
  def self.delete_from_cache(item)
    for i in self.cache
      if i.item == item.item
      # we found the item, delete it
        @@stored_blacklist.delete(i)
      end
    end
  end
  
  # clear the local cached version of the blacklist (user submitted new blacklist
  # items or removed others)
  def self.clear_cache
    @@stored_blacklist.clear
  end
    
end