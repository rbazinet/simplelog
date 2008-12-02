# $Id: preference.rb 300 2007-02-01 23:01:00Z garrett $

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

class Preference < ActiveRecord::Base
  
  #
  # this model simply retrieves and sets preference values from the db
  #
  
  # get a preference value
  def self.get_setting(name)
    # drop the case
    name = name.downcase
    # check for it
    if !@@stored_prefs[name]
      #logger.warn("WE ARE HITTING DB FOR: #{name.downcase} (cache length: #{@@stored_prefs.length.to_s})")
      #logger.warn("CURRENT CACHE: #{@@stored_prefs.inspect}")
      result = Preference.find(:first, :conditions => ['name = ?', name])
      if result
      # we found our preference, return the value
        @@stored_prefs[name] = result.value    
        return result.value
      end
      # if we've got nothing, let's return an empty string
      @@stored_prefs[name] = ''
    else
      return @@stored_prefs[name]
    end
  end
  
  # clear the local cached version of prefs (user submitted prefs save or asked
  # us to clear the cache)
  def self.clear_hash
    @@stored_prefs.clear
  end
  
  # set a preference to a value
  def self.set_setting(name, value)
    # drop the case
    name = name.downcase
    # find it
    pref = Preference.find(:first, :conditions => ['name = ?', name])
    if pref
      pref.update_attribute('value', value)
      # update the preference cache
      @@stored_prefs[name] = value
    end
  end
  
end