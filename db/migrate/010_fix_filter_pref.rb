# $Id: 010_fix_filter_pref.rb 211 2006-08-07 21:17:25Z garrett $

#
# this migration for 1.1 fixes the text_filter pref description
#

class FixFilterPref < ActiveRecord::Migration
  def self.up
    ds = 'Choose between <a href="http://daringfireball.net/projects/markdown" title="Markdown" target="_blank">Markdown</a>, <a href="http://www.textism.com/tools/textile" title="Textile" target="_blank">Textile</a> or two plain text formats to simplify your writing experience.'
    execute "UPDATE preferences SET description = '#{ds}' WHERE name = 'text_filter'"
  end

  def self.down
  end
end