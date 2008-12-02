# $Id: 014_comments.rb 285 2007-01-24 23:49:56Z garrett $

#
# migration for 1.3 adds comments
#

require 'server.rb'

class Comments < ActiveRecord::Migration
  def self.up
    create_table "comments" do |t|
      t.column "post_id", :integer
      t.column "name", :string
      t.column "email", :string
      t.column "url", :string
      t.column "subject", :string
      t.column "synd_title", :string
      t.column "body", :text
      t.column "body_raw", :text
      t.column "body_searchable", :text
      t.column "ip", :string
      t.column "is_approved", :bool, :default => false
      t.column "created_at", :datetime, :null => false
      t.column "modified_at", :datetime, :null => false
    end
    
    create_table "blacklist" do |t|
      t.column "item", :string
      t.column "created_at", :datetime, :null => false
    end
    
    nn1 = 'Turn commenting on?'
    ds1 = 'Turn the commenting features on?'
    nn2 = 'Comments by default?'
    ds2 = 'Allow comments on posts by default (you can override this per post)?'
    nn3 = 'Always approve?'
    ds3 = 'Should comments be approved by default (unapproved comments do not appear on your site)?'
    nn4 = 'Return to comment?'
    ds4 = 'After updating a comment, return to it rather than the list?'
    nn5 = 'Allow subjects?'
    ds5 = 'Allow commenter to add a subject line to comments?'
    nn6 = 'Preview by default?'
    ds6 = 'Show comment preview in admin section by default?'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'commenting_on', 'yes')"
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn2}', '#{ds2}', 'comment_default', 'no')"
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn3}', '#{ds3}', 'comments_approved', 'no')"
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn4}', '#{ds4}', 'return_to_comment', 'no')"
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn5}', '#{ds5}', 'comment_subjects', 'no')"
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn6}', '#{ds6}', 'comment_preview_by_default', 'no')"
  end

  def self.down
    drop_table "comments"
    drop_table "blacklist"
    execute "DELETE FROM preferences WHERE name = 'commenting_on'"
    execute "DELETE FROM preferences WHERE name = 'comment_default'"
    execute "DELETE FROM preferences WHERE name = 'comments_approved'"
    execute "DELETE FROM preferences WHERE name = 'return_to_comment'"
    execute "DELETE FROM preferences WHERE name = 'comment_subjects'"
    execute "DELETE FROM preferences WHERE name = 'comment_preview_by_default'"
  end
end