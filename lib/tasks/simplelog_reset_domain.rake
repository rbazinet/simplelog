# $Id: simplelog_reset_domain.rake 300 2007-02-01 23:01:00Z garrett $

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
# this rake task will reset the domain preference set in the DB
# and is useful in cases when you accidentally set it to the wrong
# value and don't want to have to connect to the DB itself
#

namespace :simplelog do

  namespace :reset do
    
    desc "Reset your domain preference to '', or pass new value with VALUE=X (ex: rake simplelog:reset:domain VALUE=mysite.com"
    task :domain => :environment do
      
      require 'preference'
      new_val = (ENV.include?('VALUE') ? ENV['VALUE'] : '')
      puts "Resetting domain preference to '#{new_val}'..."
      Preference.set_setting('domain', new_val)
      puts "Done! Clearing cache..."
      # clear the theme cache
      FileUtils.rm_r "#{RAILS_ROOT}/public/themes", :force => true
      # unset the theme
      @@gm_curr_theme = nil
      # unset prefs hash
      Preference.clear_hash
      puts "Done! You might want to restart your application/server."
      
    end
    
  end
  
end