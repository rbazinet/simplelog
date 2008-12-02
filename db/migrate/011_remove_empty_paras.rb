# $Id: 011_remove_empty_paras.rb 218 2006-08-11 14:40:20Z garrett $

#
# this migration for 1.1.1 removes empty paragraphs in extended content
# due to a bug in 1.1 that was fixed
#

class RemoveEmptyParas < ActiveRecord::Migration
  def self.up
    # grab 'em
    posts = Post.find(:all)
    
    # loop
    for p in posts
      if p.extended == '<p></p>'
        execute "update posts set extended = '' where id = #{p.id}"
      else
        next
      end
    end
    # done
  end

  def self.down
  end
end