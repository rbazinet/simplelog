# $Id: tag.rb 300 2007-02-01 23:01:00Z garrett $

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

class Tag < ActiveRecord::Base
  
  # validations
  # make sure we've got a name (especially after cleaning it up)
  validates_presence_of :name, :on => :update
  validates_presence_of :name, :on => :create
  
  # this removes special characters and spaces and quotes before validating
  def before_validation_on_create
    self.name = self.name.gsub(' ', '').gsub("'", '').gsub(/[^a-zA-Z0-9 ]/, '')
  end
  # do the same when updating
  def before_validation_on_update
    before_validation_on_create
  end
  
  # find all tags in the db that contain string
	def self.find_by_string(str, limit = 20)
	  # use plain old SQL to find this, it's not that complicated
	  results = Tag.find(:all, {:select => 'tags.id, tags.name, count(tags_posts.tag_id) as post_count', :joins => 'left outer join tags_posts on tags.id = tags_posts.tag_id', :group => 'tags.id, tags.name', :conditions => ['name like ?', '%' + str + '%'], :limit => limit})
	  return results
	end
  
end