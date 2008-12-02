# $Id: 023_fix_comment_status.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.5 fixes postgresql issues with null statuses
#

class FixCommentStatus < ActiveRecord::Migration
  def self.up
    execute "update posts set comment_status = 0 where comment_status is null"
  end

  def self.down
  end
end