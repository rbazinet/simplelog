# $Id: 003_add_prefs.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.1 adds a few extra preferences
#

class AddPrefs < ActiveRecord::Migration
  def self.up
    nn1 = 'Encode entities?'
    ds1 = 'Encode non-standard entities in your text (like &aelig; or &ccedil;)?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'encode_entities', 'no')"
  end

  def self.down
    execute "DELETE FROM preferences WHERE name = 'encode_entities'"
  end
end