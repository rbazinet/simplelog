# $Id: 022_clean_sessions_again.rb 261 2006-10-23 21:26:54Z garrett $

#
# just clean the sessions table again (i need to add this to the app somewhere)
#

class CleanSessionsAgain < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM sessions"
  end

  def self.down
  end
end
