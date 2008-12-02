# $Id: 007_remove_index.rb 199 2006-08-01 20:53:14Z garrett $

#
# this migration for 1.1 removes the index we created in our first migration
# because we no longer use it
#

require 'server.rb'

class RemoveIndex < ActiveRecord::Migration
  def self.up
    if SL_CONFIG[:DB_TYPE_MYSQL] == 'yes'
      # add a fulltext index if we're using mysql
      execute "ALTER TABLE posts DROP INDEX searchable"
    end
  end

  def self.down
    if SL_CONFIG[:DB_TYPE_MYSQL] == 'yes'
      # add a fulltext index if we're using mysql
      execute "ALTER TABLE posts ADD FULLTEXT searchable (title, body, extended)"
    end
  end
end
