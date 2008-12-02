# $Id: 008_add_post_columns.rb 206 2006-08-02 18:47:26Z garrett $

#
# this migration for 1.1 adds some new columns to the post table
# and then generates content for them
#

class AddPostColumns < ActiveRecord::Migration
  def self.up
    add_column "posts", "body_searchable", :text
    add_column "posts", "extended_searchable", :text
    add_column "posts", "text_filter", :string
    
    # now let's create searchable content on all posts
    posts = Post.find(:all)
    
    # loop
    for p in posts
      sql = ''
      b_searchable = Post.strip_html(p.body, [], true, true)
      b_searchable = b_searchable.gsub("'", "\\\\'")
      sql += 'update posts set body_searchable = \'' + b_searchable + '\', '
      if p.extended_raw != ''
        e_searchable = Post.strip_html(p.extended, [], true, true)
        e_searchable = e_searchable.gsub("'", "\\\\'")
        sql += 'extended_searchable = \'' + e_searchable + '\', '
      end
      sql += "text_filter = '#{(Preference.get_setting('TEXT_FILTER') != '' ? Preference.get_setting('TEXT_FILTER') : 'markdown')}' where id = #{p.id.to_s}"
      execute sql
    end
    # done
    
  end

  def self.down
    remove_column "posts", "body_searchable"
    remove_column "posts", "body_searchable"
    remove_column "posts", "text_filter"
  end
end
