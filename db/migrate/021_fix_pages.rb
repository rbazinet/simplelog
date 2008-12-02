# $Id: 021_fix_pages.rb 260 2006-10-23 15:03:03Z garrett $

#
# migration for 1.5 fixes some pages stuff
#

class FixPages < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM preferences where name = 'page_simple_titles'"
    add_column "pages", "title", :string, :limit => 128
    execute "UPDATE pages set title = ''"
  end

  def self.down
    nn1 = 'Use simple titles?'
    ds1 = 'Use the first five words of your page as its link on the site</span></label><label class="left" for=""><span class="small gray"> (<a href="/admin/help#hq16" title="Help: What does the &quot;Use simple titles&quot; preference do in regards to pages?" target="_blank">details</a>)?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'page_simple_titles', 'no')"
    remove_column "pages", "title"
  end
end