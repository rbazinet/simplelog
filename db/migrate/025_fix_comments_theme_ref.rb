# $Id: 025_fix_comments_theme_ref.rb 267 2006-11-06 22:02:10Z garrett $

#
# this migration for 1.5 updates reference to a certain theme
#

class FixCommentsThemeRef < ActiveRecord::Migration
  def self.up
    execute "UPDATE preferences SET value = 'default_with_comments' WHERE (name = 'current_theme' and value = 'default with comments')"
  end

  def self.down
  end
end