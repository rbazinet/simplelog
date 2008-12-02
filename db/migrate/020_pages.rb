# $Id: 020_pages.rb 261 2006-10-23 21:26:54Z garrett $

#
# migration for 1.5 adds support for "static" pages
#

class Pages < ActiveRecord::Migration
  def self.up
    create_table "pages" do |t|
      t.column "permalink", :string, :limit => 128
      t.column "body_raw", :text
      t.column "body", :text
      t.column "is_active", :boolean, :default => true
      t.column "created_at", :datetime
      t.column "modified_at", :datetime
      t.column "text_filter", :string
    end
    nn = 'Return to page?'
    ds = 'After updating a page, return to it rather than the list?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn}', '#{ds}', 'return_to_page', 'no')"
    nn1 = 'Use simple titles?'
    ds1 = 'Use the first five words of your page as its link on the site</span></label><label class="left" for=""><span class="small gray"> (<a href="/admin/help#hq16" title="Help: What does the &quot;Use simple titles&quot; preference do in regards to pages?" target="_blank">details</a>)?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'page_simple_titles', 'no')"
  end

  def self.down
    drop_table "pages"
    execute "DELETE FROM preferences WHERE name = 'return_to_page'"
    execute "DELETE FROM preferences WHERE name = 'page_simple_titles'"
  end
end