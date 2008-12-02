# $Id: simplelog_rebuild_posts.rake 300 2007-02-01 23:01:00Z garrett $

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

#
# this task will rebuild your posts--useful if you change your encoding
# or text filter preferences
#

namespace :simplelog do
  
  namespace :content do
    
    desc "Rebuild all your posts with current preferences"
    task :rebuild => :environment do
  
      puts "Grabbing all of your posts..."
      posts = Post.find(:all)
      puts "Done!"
      puts "Rebuilding #{posts.length} post#{'s' if posts.length != 1}..."
      post_params = Hash.new
      c = 1
      for p in posts
        post_params[:body_raw] = p.body_raw
        post_params[:extended_raw] = p.extended_raw
        p.update_attributes(post_params)
        puts "Rebuilt \"#{p.title}\" (#{c} of #{posts.length})"
        c = c+1
      end
      puts "All Done!"
  
    end
    
  end

end