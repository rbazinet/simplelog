# $Id: 015_clean_sessions.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.3 just cleans the sessions table... normally, people should
# do this regularly, but they might not have in a long while so this will do it
#

class CleanSessions < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM sessions"
  end

  def self.down
  end
end