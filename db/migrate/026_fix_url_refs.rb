# $Id: 026_fix_url_refs.rb 270 2006-12-04 20:16:09Z garrett $

#
# this migration for 1.5 fixes references to literal admin urls in prefs
#

class FixUrlRefs < ActiveRecord::Migration
  def self.up
    @prefs = Preference.find(:all)
    for p in @prefs
      currently = p.description
      currently = currently.gsub('href="/admin/help', 'href="help')
      p.update_attribute('description', currently)
    end
  end

  def self.down
  end
end