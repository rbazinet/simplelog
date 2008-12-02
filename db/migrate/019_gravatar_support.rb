# $Id: 019_gravatar_support.rb 248 2006-09-15 21:46:37Z garrett $

#
# migration for 1.3 adds pref for gravatar support
#

class GravatarSupport < ActiveRecord::Migration
  def self.up
    nn = 'Show Gravatars?'
    ds = 'Include <a href="http://gravatar.com" title="Learn more about Gravatars" target="_blank">Gravatar</a> icons in comment display?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn}', '#{ds}', 'show_gravatars', 'no')"
  end

  def self.down
    execute "DELETE FROM preferences WHERE name = 'show_gravatars'"
  end
end