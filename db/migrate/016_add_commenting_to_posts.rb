# $Id: 016_add_commenting_to_posts.rb 261 2006-10-23 21:26:54Z garrett $

#
# migration for 1.3 which adds per-post comment boolean
#

class AddCommentingToPosts < ActiveRecord::Migration
  def self.up
    add_column "posts", "comment_status", :integer, :default => 0
  end

  def self.down
    remove_column "posts", "comment_status"
  end
end