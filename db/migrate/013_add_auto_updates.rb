# $Id: 013_add_auto_updates.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.2 adds a table that aides auto update checking, and
# a preference to turn auto-updates on and off
#

class AddAutoUpdates < ActiveRecord::Migration
  def self.up
    create_table "updates" do |t|
      t.column "last_checked_at", :datetime
      t.column "update_available", :bool, :default => false
      t.column "update_version", :string
    end
    execute "INSERT INTO updates (last_checked_at, update_version) VALUES ('1981-05-15 00:00:00', '1.2')"
    
    nn = 'Auto update check?'
    ds = 'Do you want SimpleLog to automatically check for updates occasionally?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn}', '#{ds}', 'check_for_updates', 'yes')"
  end

  def self.down
    drop_table "updates"
    execute "DELETE FROM preferences WHERE name = 'check_for_updates'"
  end
end