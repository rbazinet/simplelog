# $Id: 005_fix_mint_pref.rb 174 2006-07-27 18:28:14Z garrett $

#
# this migration for 1.1 fixes the mint pref description
#

class FixMintPref < ActiveRecord::Migration
  def self.up
    nn = 'Mint location'
    ds = 'The location you installed <a href="http://haveamint.com" title="Mint" target="_blank">Mint</a> into, if you have (<a href="/admin/help#hq13" title="Help: How should I enter my &quot;Mint location&quot;?" target="_blank">see help</a> for details and examples).'
    execute "UPDATE preferences SET nice_name = '#{nn}', description = '#{ds}' WHERE name = 'mint_dir'"
  end

  def self.down
  end
end