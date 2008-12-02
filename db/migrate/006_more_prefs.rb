# $Id: 006_more_prefs.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.1 adds a few more prefs to the app
#

class MorePrefs < ActiveRecord::Migration
  def self.up
    nn1 = 'Show tags by default?'
    ds1 = 'Always show the list of existing tags on the post form?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'all_tags_by_default', 'no')"
    
    nn2 = 'Return to post?'
    ds2 = 'After updating a post, return to it rather than the list?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn2}', '#{ds2}', 'return_to_post', 'no')"
  end

  def self.down
    execute "DELETE FROM preferences WHERE name = 'all_tags_by_default'"
    execute "DELETE FROM preferences WHERE name = 'return_to_post'"
  end
end
