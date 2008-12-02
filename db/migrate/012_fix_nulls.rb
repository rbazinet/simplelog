# $Id: 012_fix_nulls.rb 220 2006-08-14 15:20:42Z garrett $

#
# this migration for 1.1.2 fixes certain NULL values in the db
#

class FixNulls < ActiveRecord::Migration
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