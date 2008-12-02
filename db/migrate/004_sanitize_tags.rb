# $Id: 004_sanitize_tags.rb 170 2006-07-26 18:36:17Z garrett $

#
# this migration for 1.1 sanitizes tags, removing spaces, single- and
# double-quotes and all special characters
#

class SanitizeTags < ActiveRecord::Migration
  def self.up
    # grab the tags
    tags = Tag.find(:all)
    for t in tags
      # clean the name
      name = t.name.gsub(' ', '').gsub("'", '').gsub(/[^a-zA-Z0-9 ]/, '')
      # check to see if the name is blank now, if it is, destroy the tag
      if name == ''
        Tag.find(t.id).destroy
        next
      end
      # update
      t.update_attributes(:name => name)
    end
    # done!
  end

  def self.down
  end
end
