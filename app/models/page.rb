# $Id: page.rb 300 2007-02-01 23:01:00Z garrett $

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

# using a search library
require_dependency 'search'

class Page < ActiveRecord::Base
  
  # set up search fields
  searches_on :title, :body_raw
  
  # validations
  validates_presence_of :permalink, :title, :body_raw
  validates_exclusion_of :permalink, :in => %w( show ), :message => 'is set to a reserved word ("show")'
  validates_uniqueness_of :permalink # brute force to make sure we don't let a dup in
  validates_each :body_raw, :allow_nil => true do |record, attr, value|
  # this tests the content first... makes sure we don't have malformed XHTML (which won't save!)
    Post.create_clean_content(value) rescue record.errors.add(attr, 'contains malformed XHTML')
  end
  
  # convert text using our filter and clean up dashes
  # we can return on errors when cleaning content because we've got a
  # validator which checks to make sure that content works... if it doesn't
  # we'll get an error anyway, so we don't need to continue doing this stuff
  def before_validation_on_create
		self.body = Post.create_clean_content(self.body_raw, self.text_filter) rescue return
		self.permalink = Post.to_permalink(self.permalink) if self.permalink and self.permalink != ''
  end
  
  # convert text using our filter and clean up dashes
  # see above for info on the rescue returns
	def before_validation_on_update
		before_validation_on_create
	end
	
	# before a page is created, set its modification date to now
	def before_create
	  temp_time = Time.sl_local
	  self.created_at = temp_time
	  self.modified_at = temp_time
  end
  
  def before_update
    self.modified_at = Time.sl_local
  end
  
  # get a page based on permalink
  def self.find_by_link(permalink)
		self.find(:first, :conditions => ['is_active = true and permalink = ?', permalink])
	end
	
	# find all pages in the db that contain string
	def self.find_by_string(str, limit = 20, active_only = false)
	  # use the search lib to run this search
	  results = self.search(str, {:conditions => (active_only ? 'is_active = true' : nil), :limit => limit})
	  if (results.length > 1) or (str.downcase.index(' and '))
	  # if the first search returned something or there was an AND operator
	    return results
    else
    # first search didn't find anthing, let's try it with the OR operator
      simple_str = str.gsub(' ',' OR ')
      return self.search(simple_str, {:conditions => (active_only ? 'is_active = true' : nil), :limit => limit})
    end
	end
  
end