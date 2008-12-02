# $Id: 009_tweak_prefs.rb 261 2006-10-23 21:26:54Z garrett $

#
# this migration for 1.1 tweaks a few of the preferences
#

class TweakPrefs < ActiveRecord::Migration
  def self.up
    nn = 'Default text filter'
    ds = 'Choose between <a href="http://daringfireball.net/projects/markdown" title="Markdown" target="_blank">Markdown</a>, <a href="http://www.textism.com/tools/textile" title="Textile" target="_blank">Textile</a> or plain text to simplify your writing experience.'
    execute "UPDATE preferences SET nice_name = '#{nn}', description = '#{ds}' WHERE name = 'text_filter'"
  end

  def self.down
  end
end
