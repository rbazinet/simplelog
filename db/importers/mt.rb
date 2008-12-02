# $Id: mt.rb 300 2007-02-01 23:01:00Z garrett $

#--
# Copyright (C) 2006-2007 Garrett Murray
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program (doc/LICENSE); if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301 USA.
#++

#
# mt importer
# imports your content from movable type 3+ blogs to simplelog
#
# YOU SHOULD GO THROUGH THE SIMPLELOG INSTALL PROCESS BEFORE RUNNING THIS
# -----------------------------------------------------------------------
#
# to use:
# 1. in your MT install, go to import/export
# 2. click "export entries from [your blog name]" and save the file as mt.txt
# 3. copy mt.txt file to db/content_files
# 4. run: rake import_mt_content
#
# yay!
#

require File.dirname(__FILE__) + '/../../config/environment'
require 'find'
require 'post'
require 'preference'
require 'application'

puts "\nOpening your exported file 'mt.txt'..."

# open the file
begin
  mt_data_text = File.read(RAILS_ROOT + '/db/content_files/mt.txt')
  puts "File opened successfully!\n\nGrabbing entries..."
rescue
# file doesn't exist... tell user and then exit
  puts "File not found!\n\nPlease rename your exported Movable Type-formatted file 'mt.txt' and place it in the db/content_files directory BEFORE running this script.\n\n"
  # kill it
  exit
end

# get the entries in an array
entries = mt_data_text.split('--------')
puts (entries.length-1).to_s + " #{(entries.length-1) == 1 ? 'entry' : 'entries'} found!\n\nProcessing entries (this could take several minutes)..." if entries.length > 0

# count them
c  = 0 # total
ec = 0 # errors
gc = 0 # imported
dc = 0 # duplicates

if entries.length > 0
  for e in entries
  
    # ++
    c = c+1
  
    # last one is always blank
    break if c == entries.length
  
    # get some prefs
    simple_titles_pref = Preference.get_setting('SIMPLE_TITLES') rescue 'no'
    text_filter_pref = Preference.get_setting('TEXT_FILTER') rescue 'markdown'
  
    # grab the date
    date = e.split(/\nDATE: (.+)?\n/)
    date = date[1]
    # fix 12h to 24h
    if date[20..21] == 'PM'
      if date[11..12].to_i != 12
        hours = (date[11..12].to_i)+12
      else
        hours = 12
      end
    else
      if date[11..12].to_i == 12
        hours = 0
      else
        hours = date[11..12]
      end
    end
    hours = hours.to_s
    hours = '0' + hours if hours.length == 1
    date = "#{date[6..9]}-#{date[0..1]}-#{date[3..4]} #{hours}:#{date[14..15]}:#{date[17..18]}"
  
    # get the summary
    summary = e.split(/\n-----\nEXCERPT:\n([\w\W\s\S\d\D\n]*)?-----\nKEYWORDS/)
    summary = summary[1]
    if summary
      summary = summary.strip
    else
      summary = ''
    end
    
    # get the filter type
    filter_type = e.split(/\nCONVERT BREAKS: (.+)?\n/)
    if filter_type[1]
      filter_type = filter_type[1]
      if filter_type == '1'
        filter_type = 'convert line breaks'
      elsif filter_type == '0'
        filter_type = 'plain text'
      elsif filter_type.index('markdown')
        filter_type = 'markdown'
      elsif filter_type.index('textile')
        filter_type = 'textile'
      else
        filter_type = text_filter_pref
      end
    else
      filter_type = text_filter_pref
    end
  
    # get the body text
    body = e.split(/\n-----\nBODY:\n([\w\W\s\S\d\D\n]*)?-----\nEXTENDED/)
    body = body[1]
    if body
      body = body.strip
    else
      body = ''
    end
    body_filtered = Post.create_clean_content(body, filter_type)
  
    # get the extended text
    extended = e.split(/\n-----\nEXTENDED BODY:\n([\w\W\s\S\d\D\n]*)?-----\nEXCERPT/)
    extended = extended[1]
    if extended
      extended = extended.strip
    else
      extended = ''
    end
    extended_filtered = Post.create_clean_content(extended, filter_type)
  
    # grab the title
    title = e.split(/\nTITLE: ([\w\W\s\S\d\D]*)?STATUS/)
    title = title[1]
    if title
      title = title.strip
    else
      title = ''
    end
    title = Post.to_synd_title(body) if title == ''
  
    # create a permalink
    permalink = Post.to_permalink((simple_titles_pref == 'yes' ? body : title))
  
    # check if post is active
    status = e.split(/\nSTATUS: (.+)?\n/)
    status = status[1]
    if status and status == 'Draft'
      is_active = 0
    else
      is_active = 1
    end
  
    # get the tags
    tags_list = ''
    tags = e.split('DATE:')
    tags = tags[0]
    if tags
      tags = tags.split(/ALLOW PINGS: [0-9]+\n/)
      tags = tags[1]
      if tags
        tags = tags.gsub(/PRIMARY CATEGORY: .+?\n/, '')
        tags = tags.split(/CATEGORY: (.+)?\n/)
        
        tags_list = ''
        for t in tags
          t = t.strip
          tags_list += (tags_list != '' ? ' ' : '') + t.gsub("'", '').gsub(/[^a-zA-Z0-9]/, '') if t != ''
        end
      end
    end
  
    # create the post
    @post = Post.new
    @post.author_id = 1
    @post.created_at = date
    @post.modified_at = date
    @post.permalink = permalink
    @post.title = title
    @post.synd_title = (simple_titles_pref == 'yes' ? Post.to_synd_title(body) : title)
    @post.summary = summary
    @post.body_raw = body
    @post.extended_raw = extended
    @post.body = body_filtered
    @post.extended = extended_filtered
    @post.text_filter = filter_type
    @post.is_active = is_active
    @post.custom_field_1 = ''
    @post.custom_field_2 = ''
    @post.custom_field_3 = ''
    
    @dup = Post.find(:first, :conditions => ['title = ? and summary = ? and body_raw = ? and extended_raw = ?', title, summary, body, extended])
    if @dup
    # this is a duplicate, don't import it again
      dc = dc+1
    else
      # save it
      if !@post.save
        ec = ec+1
        # tell them about the error
        puts "Error creating entry " + c.to_s + ", check structure of content file!"
      else
        gc = gc+1
        # tell them what we did
        puts "Created entry (#{c.to_s} of #{entries.length-1}): '#{title}'"
        # tag it
        @post.tag(tags_list, :clear => true) if tags_list != ''
      end
    end

  end
  
  # we're done, let's report our numbers
  puts "Finished processing entries!\n\n" + gc.to_s + " #{(gc == 1 ? 'entry' : 'entries')} imported!"
  puts dc.to_s + " #{(dc == 1 ? 'entry' : 'entries')} were ignored because they were duplicates!" if dc > 0
  puts ec.to_s + " #{(gc == 1 ? 'entry' : 'entries')} could not be imported!" if ec > 0
  # that's it!
  puts "\nAll done! You may delete the 'mt.txt' file from db/content_files now if you wish.\n\n"
else
  puts "No entries were found!\n\nIf you believe this to be an error, please check your 'mt.txt' file and try again.\n\n"
end