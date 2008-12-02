# $Id: 027_add_another_pref.rb 275 2007-01-11 21:06:20Z garrett $

#
# this migration for 2.0 tweaks one pref and adds another
#

class AddAnotherPref < ActiveRecord::Migration
  def self.up
    execute "UPDATE preferences SET nice_name = 'Items in quicksearch' WHERE name = 'search_results'"
    
    nn1 = 'Items in full search'
    ds1 = 'Number of items to return in full search results.'
    execute "INSERT INTO preferences (nice_name, description, name, value) VALUES ('#{nn1}', '#{ds1}', 'search_results_full', '100')"
  end

  def self.down
    execute "UPDATE preferences SET nice_name = 'Items in search results' WHERE name = 'search_results'"
    execute "DELETE FROM preferences WHERE name = 'search_results_full'"
  end
end