# $Id: 028_fix_blacklist_nulls.rb 296 2007-01-30 22:31:51Z garrett $

#
# migration for 2.0 which fixed null values in the blacklist table
#

class FixBlacklistNulls < ActiveRecord::Migration
  def self.up
    # grab the time
    the_time = (Time.now+(Preference.get_setting('OFFSET').to_i*60*60)).getgm.strftime('%Y-%m-%d %H:%M:%S')
    execute "update blacklist set created_at = '#{the_time}' where created_at is null"
  end

  def self.down
  end
end