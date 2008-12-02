# $Id: 024_archive_tokens.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.5 creates a preference for choosing an archive token
#

class ArchiveTokens < ActiveRecord::Migration
  def self.up
    nn = 'Archive token'
    ds = 'How you wish to refer to your archives in URLs (http://yoursite.com/<b>token</b>/1981/5/15/happy_birthday)'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn}', '#{ds}', 'archive_token', 'past')"
  end

  def self.down
    execute "DELETE FROM preferences WHERE name = 'archive_token'"
  end
end