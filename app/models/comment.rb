# $Id: comment.rb 324 2007-02-07 16:12:13Z garrett $

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

# using a search library
require_dependency 'search'

class Comment < ActiveRecord::Base
  
  # associations
  belongs_to :post
  
  # set up search fields
  searches_on :body_searchable
  
  # validations
  validates_presence_of :post_id, :email, :body_raw
  validates_format_of :email, :with => /^([0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$/i, :message => 'must be a valid email address', :if => Proc.new { |comment| comment.email != '' }
  
  # absolutely destroys any tags and any remaining < and >
  def self.kill_tags(input)
    if !input
    # if we're passed nil, let's be kind and return an empty string
      return ''
    end
    input = input.gsub(/<\/?[^>]*>/, '')
    input = input.gsub('<', '&lt;')
    input = input.gsub('>', '&gt;')
  end
  
  # convert text using our filter and clean up dashes
  # we can return on errors when cleaning content because we've got a
  # validator which checks to make sure that content works... if it doesn't
  # we'll get an error anyway, so we don't need to continue doing this stuff
  def before_validation_on_create
    self.body = Post.create_clean_content(Comment.kill_tags(self.body_raw)) rescue return
    self.body_searchable = Post.strip_html(Comment.kill_tags(self.body), [], true, true) rescue return
    # check the name and email and url
    self.name = Comment.kill_tags(self.name)
    self.email = Comment.kill_tags(self.email)
    self.url = Author.prepend_http(Comment.kill_tags(url))
		# create a syndication title
		if (Preference.get_setting('COMMENT_SUBJECTS') == 'yes' and (self.subject and self.subject != ''))
		# we allow subjects and there is one, use that
		  self.synd_title = Comment.kill_tags(self.subject)
		else
		# we either don't allow subjects or there isn't one, let's use a short version of the body
		  self.synd_title = Post.to_synd_title(self.body)
	  end
  end

  # convert text using our filter and clean up dashes
  # see above for info on the rescue returns
	def before_validation_on_update
		before_validation_on_create
	end
	
	# check for spam on create
	def validate_on_create
	  if (!self.post_id or !self.email or !self.body_raw)
	    return false
    end
	  # now let's check the blacklist
    spam = false
    # grab the items
    blacklist_items = (Blacklist.cache.length > 0 ? Blacklist.cache : Blacklist.find(:all))
    if blacklist_items and blacklist_items.length > 0
      # loop
      for i in blacklist_items
        # check for this hit
        if (self.ip and self.ip.index(/#{i.item}/))
        # found it!
          spam = true
          logger.warn("[Blacklist #{Time.sl_local.strftime('%m-%d-%Y %H%:%M:%S')}]: IP #{self.ip} is blacklisted, blocking comment.")
          # we might as well stop now
          break
        # if we didn't find a blacklist IP, check the body now
        elsif self.body.index(/#{i.item}/)
        # found it!
          spam = true
          logger.warn("[Blacklist #{Time.sl_local.strftime('%m-%d-%Y %H%:%M:%S')}]: Body contained blacklisted item: \"#{i.item}\", blocking comment.")
          # we might as well stop now
          break
        # if we didn't find it, check the name now
        elsif (self.name and self.name.index(/#{i.item}/))
          spam = true
          logger.warn("[Blacklist #{Time.sl_local.strftime('%m-%d-%Y %H%:%M:%S')}]: Name contained blacklisted item: \"#{i.item}\", blocking comment.")
          # we might as well stop now
          break
        # if we didn't find it, check the email now
        elsif self.email.index(/#{i.item}/)
          spam = true
          logger.warn("[Blacklist #{Time.sl_local.strftime('%m-%d-%Y %H%:%M:%S')}]: Email contained blacklisted item: \"#{i.item}\", blocking comment.")
          # we might as well stop now
          break
        # if we didn't find it, check the url now
        elsif (self.url and self.url.index(/#{i.item}/))
          spam = true
          logger.warn("[Blacklist #{Time.sl_local.strftime('%m-%d-%Y %H%:%M:%S')}]: URL contained blacklisted item: \"#{i.item}\", blocking comment.")
          # we might as well stop now
          break
        end
      end
    end
    if spam
      errors.add_to_base('Your comment either contains spam or your IP address has been blocked. If you feel this is in error, please contact the site\'s author.')
      return false
    else
      return true
    end
  end
  
	# before a comment is created, set its modification date to now
	def before_create
	  # if we approve by default, let's do that
	  self.is_approved = (Preference.get_setting('COMMENTS_APPROVED') == 'yes' ? true : false)
	  # set modification date
	  self.modified_at = Time.sl_local
	  # set created date
	  self.created_at = Time.sl_local
  end
  
  # get a list of comments for the feed
  def self.find_for_feed
    self.find(:all, :conditions => 'is_approved = true', :order => 'created_at desc', :limit => 20)
  end
  
  # find all comments in the db that contain string
	def self.find_by_string(str, limit = Preference.get_setting('SEARCH_RESULTS'))
	  # use the search lib to run this search
	  results = self.search(str, :limit => limit)
	  if (results.length > 1) or (str.downcase.index(' and '))
	  # if the first search returned something or there was an AND operator
	    return results
    else
    # first search didn't find anthing, let's try it with the OR operator
      simple_str = str.gsub(' ',' OR ')
      return self.search(simple_str, :limit => limit)
    end
	end
  
  # find only unapproved comments
  def self.find_unapproved
    self.find(:all, :conditions => ['is_approved = ?', false])
  end
  
end