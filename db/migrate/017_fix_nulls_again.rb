# $Id: 017_fix_nulls_again.rb 242 2006-09-08 21:46:05Z garrett $

#
# this migration for 1.3 fixes certain NULL values in the db (again)
#

class FixNullsAgain < ActiveRecord::Migration
  def self.up
    execute "update posts set extended_raw = '' where extended_raw is null"
    execute "update posts set extended = '' where extended is null"
    execute "update posts set body_searchable = '' where body_searchable is null"
    execute "update posts set extended_searchable = '' where extended_searchable is null"
    execute "update posts set custom_field_1 = '' where custom_field_1 is null"
    execute "update posts set custom_field_2 = '' where custom_field_2 is null"
    execute "update posts set custom_field_3 = '' where custom_field_3 is null"
  end

  def self.down
  end
end