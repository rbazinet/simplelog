# $Id: post.rb 329 2007-02-09 19:39:12Z garrett $

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

class Post < ActiveRecord::Base
  
  # for tagging
  acts_as_taggable
  
  # set up search fields
  searches_on :title, :body_searchable, :extended_searchable
  
  # associations
  belongs_to :author
  has_many :comments, :conditions => ['is_approved = ?', true], :dependent => :destroy
  
  # validations
  validates_presence_of :author_id, :title, :body_raw
  validates_uniqueness_of :permalink # brute force to make sure we don't let a dup in
  validates_each :body_raw, :extended_raw, :allow_nil => true do |record, attr, value|
  # this tests the content first... makes sure we don't have malformed XHTML (which won't save!)
    Post.create_clean_content(value) rescue record.errors.add(attr, 'contains malformed XHTML')
  end
  validates_presence_of :permalink, :if => :test_for_permalink # check for presence of permalink
  
  # this tests for a permalink if the body exists and is valid
  def test_for_permalink
    test_body = ''
    begin
      test_body = Post.create_clean_content(self.body_raw, self.text_filter)
      if test_body != ''
      # there is a body, let's check for the permalink
        return true
      else
      # no body, we'll error that first
        return false
      end
    rescue
    # bad body content, error that first
      return false
    end
  end
  
  # builds a link to a post based on its date of creation and its permalink
  def self.permalink(post, archive_token = Preference.get_setting('ARCHIVE_TOKEN'))
    # we could use stftime, but i like the month and year to be without leading zeros, so this is easier
    return Site.full_url + '/' + archive_token + '/' + post.created_at.year.to_s + '/' + post.created_at.month.to_s + '/' + post.created_at.day.to_s + '/' + post.permalink + '/'
  rescue
  # just in case something goes wrong...
    return Site.full_url
  end
  
	# strip html from a string, (optionally) allowing for certain tags to remain
  def self.strip_html(str, allow = [], add_space = false, replace_entities = false)
		if str
		  str = str.strip || ''
		  allow_arr = allow.join('|') << '|\/'
		  str = str.gsub(/<(\/|\s)*[^(#{allow_arr})][^>]*>/, (add_space ? ' ' : ''))
		  if replace_entities
		    str = str.
		      gsub('&#8211;', ' - ').   # en-dash
          gsub('&#8212;', ' -- ').  # em-dash
          gsub('&mdash;', ' -- ').  # em-dash
          gsub('&#8216;', "'").     # open single quote
          gsub('&#8217;', "'").     # close single quote
          gsub('&#8220;', '"').     # open double quote
          gsub('&#8221;', '"').     # close double quote
          gsub('&#8230;', ' ... '). # ellipsis
          gsub('&amp;',   '&').     # ampersand
          gsub('&quot;',  '"').     # quote
          gsub('&#039;',  "'").     # apos
          gsub('&lt;',    ' < ').   # less than
          gsub('&gt;',    ' > ').   # greater than
          gsub(/[ ]+/,    ' ')
        return str.strip
      else
        return str
	    end
		end
	end
	
	# this fixes redcloth issues because redcloth sucks and i hate it!
	def self.fix_redcloth(input)
	  input = input.gsub(/\>\s+?\</, '><') # get rid of newlines between tags
	  input = input.gsub(/\n{2,}/, '') # get rid of more than one newline block
	  input = input.gsub("\n", '<br/>') # replace single newline with BR
	  return input
  end
  
	# cleans up text, runs filter of your choice
  def self.create_clean_content(input, text_filter = Preference.get_setting('TEXT_FILTER'))
	  # decide which filter to use first
  	if text_filter == 'markdown'
  	  input = BlueCloth.new(input).to_html
	  elsif text_filter == 'textile'
	    input = self.fix_redcloth(RedCloth.new(input).to_html)
	  elsif text_filter == 'convert line breaks'
	    input = input.gsub(/\n\n/, '</p><p>')
	    input = input.gsub(/\n/, '<br/>')
	    input = '<p>' + input + '</p>'
	  end
		# run through rubypants if we should (pref)
		if Preference.get_setting('SMARTY_PANTS') == 'yes'
		  input = RubyPants.new(input).to_html
		elsif Preference.get_setting('NICE_DASHES') == 'yes'
		# fix mdashes if we need to (pref)
		  input = input.gsub(' -- ', '&mdash;')
		  input.gsub!('--', '&mdash;')
		  input.gsub!('&mdash;force', ' --force') # specific rage rule, ignore this
		end
		# are we encoding entities?
		if Preference.get_setting('ENCODE_ENTITIES') == 'yes'
		  input = HTMLEntities.encode_entities(input, :named)
	  end
		# all done
		return input
	end
  
  # create a URL-safe permalink from input (body text of post)
	# 
	# this is a little complicated because we need to make sure we create a unique
	# permalink, and that might require that we loop over and over until we do.
	#
	# the first time this runs, it creats a link with the default `number_words`
	# and then checks to see if that is already in use as a permalink -- if it is
	# the method runs again, but ups `number_words` +1... if THAT permalink
	# exists, this continues to loop adding +1 to `number_words` until it runs out of
	# words and, in that case, begins to add `extra_word` to the end of the permalink
	# and continues until it has a unique link.
	#
	# so, for example, if your body says "he is being linked to and loves it"
	# the permalink will be "he_is_being_linked_to" assuming there is no existing link
	# like that. if there is, it would be "he_is_being_linked_to_and" (note added word)
	# and so on, until you run out of words. if there are two posts with that exact
	# body, then the link will become "he_is_being_linked_to_and_loves_it_again" (where
	# "again" is the specified `extra_word`).
	#
	# you can change the word spacer from _ to whatever you want (or nothing) by changing
	# the default value of `word_spacer`
  def self.to_permalink(input = '', current_id = nil, number_words = 5, extra_word = 'again', previous_output = nil, loops = 0, added = 0, word_spacer = '_')
    # strip html tags and lowercase first
		words = Post.strip_html(input.downcase)
		# dump double-dashes first, cause they can cause two words to become--one...
		words.gsub!('--', ' ')
		if Preference.get_setting('TEXT_FILTER') == 'markdown'
		  # this gets rid of markdown-style links and images if necessary
		  words.gsub!(/\!\[.+?\]\(.+?\)/, '') # ![alt](url)
  		words.gsub!(/\!\[.+?\]\[.+?\]/, '') # ![alt][id]
  		words.gsub!(/\[\d+\]/i, '')         # [0]
  		words.gsub!(/\]\(.+?\)/i, '')       # ](url)
  	end
  	if Preference.get_setting('TEXT_FILTER') == 'textile'
		  # this gets rid of textile-style links and images if necessary
		  words.gsub!(/\!\S+?\!/i, '')        # !url!
		  words.gsub!(/\"\:.+?\s/i, ' ')      # ":url (note: also matches space and replaces with space)
	  end
		# split it up
		words = words.split()
		# empty string to build into
		output = ''
		# keep a tally on words we collect
		wc = 0
		for word in words
			# we should only use safe words, strip quotes and non-word chars
			word.gsub!(/['"]/, '')
			word.gsub!(/\W/, '')
			if word != ''
			# okay, we've got a word... add it to the string and count this
			  output += word + '_'
			  wc = wc+1
			end
			# are we done? (do we have all our words)
			break if wc == number_words
		end
		# trim extra dashes
		output.gsub!(/(_)$/, '')
		output.gsub!(/^(_)/, '')
		# check to see if this is the same output as last time (i.e. a short entry) and pad if necessary
		# but we'll keep the unaltered output to compare in the next loop (if it happens)
		keep_output = output
    do_loops = loops # number of loops to run
		if output == previous_output
		  # if we've never added the extra word before, only do this once no matter how many loops we've done
		  do_loops = 1 if added == 0
		  # if we've added some extra words before, but we've added fewer than the amount of loops, loop appropriately
		  do_loops = added+1 if added < loops
		  # now let's loop
		  do_loops.times do
		    output += '_' + extra_word
		  end
		  # we added an extra word, keep track of that
		  added = added+1
		end
		# let's test this to see if it's unique (note that we pass in a current_id if we have it... that's
		# because we don't want this very post to come up as a dup if we're editing an existing post)
		@test = Post.find(:all, :conditions => (current_id ? ['id != ? and permalink = ?', current_id, output] : ['permalink = ?', output]))
		if @test.length > 0
		# there was a dup, we need to run this method again
		  return Post.to_permalink(input, (current_id ? current_id : nil), (number_words+1), extra_word, keep_output, (loops+1), added)
    else
    # now let's just make sure we actually HAVE a permalink (could be blank)
      if output == ''
        return (Time.new.strftime('%Y%m%d%H%M%S') + Time.now.usec.to_s).gsub('_', word_spacer)
      else
		    return output.gsub('_', word_spacer)
		  end
    end
	end
	
	# create a `number_words`-length title for syndication purposes
	def self.to_synd_title(input, number_words = 5)
	  words = HTMLEntities.decode_entities(input)
		words = Post.strip_html(words)
		words = words.split()
		output = ''
		for word in words[0..(number_words-1)]
			output += word + ' '
		end
		return output.rstrip + '...'
	end
  
  # convert text using our filter and clean up dashes
  # we can return on errors when cleaning content because we've got a
  # validator which checks to make sure that content works... if it doesn't
  # we'll get an error anyway, so we don't need to continue doing this stuff
  def before_validation_on_create
		self.body = Post.create_clean_content(self.body_raw, self.text_filter) rescue return
		self.body_searchable = Post.strip_html(self.body, [], true, true) rescue return
		if self.extended_raw and self.extended_raw != ''
		  self.extended = Post.create_clean_content(self.extended_raw, self.text_filter) rescue return
		  self.extended_searchable = Post.strip_html(self.extended, [], true, true) rescue return
		elsif self.extended_raw == ''
		  self.extended = ''
		  self.extended_searchable = ''
	  end
		if !self.permalink or self.permalink == ''
		# no permalink was specified, so let's create one automatically
			self.permalink = Post.to_permalink((Preference.get_setting('SIMPLE_TITLES') == 'yes' ? self.body_raw : self.title))
		end
		# create a syndication title
		self.synd_title = (Preference.get_setting('SIMPLE_TITLES') ? Post.to_synd_title(self.body) : self.title)
  end

  # convert text using our filter and clean up dashes
  # see above for info on the rescue returns
	def before_validation_on_update
		before_validation_on_create
	end
	
	# before a post is created, set its modification date to now and check comment status
	def before_create
	  self.modified_at = Time.sl_local
	  # check comment status
	  self.comment_status = 0 if !self.comment_status or self.comment_status == ''
  end
  
  # just check the comment status and set it correctly if necessary
  def before_update
    # check comment status
	  self.comment_status = 0 if !self.comment_status or self.comment_status == ''
  end
	
	# get a list of posts for the index page, based on active, current posts (configure how many in preferences)
	def self.find_current
    self.find(:all, :conditions => ['is_active = ? and created_at <= ?', true, Time.sl_local], :order => 'created_at desc', :limit => Preference.get_setting('ITEMS_ON_INDEX').to_i)
  end
  
  # get a list of all posts for the archives page
  def self.find_all_posts(only_active = true)
    if only_active
      self.find(:all, :conditions => ['is_active = ? and created_at <= ?', true, Time.sl_local], :order => 'created_at desc')
    else
      self.find(:all, :order => 'created_at desc')
    end
  end
  
  # get a list of posts for the feed
  def self.find_for_feed
    self.find(:all, :conditions => ['is_active = ? and created_at <= ?', true, Time.sl_local], :order => 'created_at desc', :limit => Preference.get_setting('ITEMS_IN_FEED').to_i)
  end
  
  # get a list of posts written in a certain year
  def self.find_by_year(y)
    first_year = Time.parse("01/01/#{y}").strftime('%Y-%m-%d %H:%M:%S')
    last_year = Time.parse((Date.parse("01/01/#{y}")>>12).to_s).strftime('%Y-%m-%d %H:%M:%S')
    self.find(:all, :conditions => ['is_active = ? and (created_at >= ? and created_at < ?) and created_at <= ?', true, first_year, last_year, Time.sl_local], :order => 'created_at desc')
  end
  
  # get a list of posts written in a certain month
  def self.find_by_month(m, y)
    first_month = Time.parse("#{m}/01/#{y}").strftime('%Y-%m-%d %H:%M:%S')
    last_month = Time.parse((Date.parse("#{m}/01/#{y}")>>1).to_s).strftime('%Y-%m-%d %H:%M:%S')
    self.find(:all, :conditions => ['is_active = ? and (created_at >= ? and created_at < ?) and created_at <= ?', true, first_month, last_month, Time.sl_local], :order => 'created_at desc')
  end
  
  # get a list of posts written on a certain day
  def self.find_by_day(d, m, y)
    first_day = Time.parse("#{m}/#{d}/#{y}").strftime('%Y-%m-%d %H:%M:%S')
    last_day = Time.parse((Date.parse("#{m}/#{d}/#{y}")+1).to_s).strftime('%Y-%m-%d %H:%M:%S')
    self.find(:all, :conditions => ['is_active = ? and (created_at >= ? and created_at < ?) and created_at <= ?', true, first_day, last_day, Time.sl_local], :order => 'created_at desc')
  end
  
  # get a list of posts written by `author`
  def self.find_by_author(author)
    self.find(:all, :conditions => ['is_active = ? and author_id = ? and created_at <= ?', true, author, Time.sl_local], :order => 'created_at desc')
  end
  
  # get a list of posts tagged with `tag`
  def self.find_by_tag(tag, only_active = true)
    tag = tag.gsub("'", "''") # protect against quotes
    if only_active
      self.find_tagged_with(:all => tag, :conditions => ['is_active = ? and created_at <= ?', true, Time.sl_local], :order => 'created_at desc')
    else
      self.find_tagged_with(:all => tag, :order => 'created_at desc')
    end
  end
  
  # get a single post based on permalink
  def self.find_individual(permalink)
		self.find(:all, :conditions => ['is_active = ? and permalink = ? and created_at <= ?', true, permalink, Time.sl_local])
	end
	
	# find the previous active post
	def self.find_previous(post)
	  self.find(:all, :conditions => ['is_active = ? and created_at < ? and created_at <= ?', true, post.created_at.strftime('%Y-%m-%d %H:%M:%S'), Time.sl_local], :order => 'created_at desc', :limit => 1)
	end
	
	# find the next active post
	def self.find_next(post)
	  self.find(:all, :conditions => ['is_active = ? and created_at > ? and created_at <= ?', true, post.created_at.strftime('%Y-%m-%d %H:%M:%S'), Time.sl_local], :order => 'created_at asc', :limit => 1)
	end
	
	# find all posts in the db that contain string
	def self.find_by_string(str, limit = Preference.get_setting('SEARCH_RESULTS'), active_only = true)
	  # use the search lib to run this search
	  results = self.search(str, {:conditions => (active_only ? "is_active = #{true} and created_at <= '#{Time.sl_local_db}'" : nil), :limit => limit})
	  if (results.length > 1) or (str.downcase.index(' and '))
	  # if the first search returned something or there was an AND operator
	    return results
    else
    # first search didn't find anthing, let's try it with the OR operator
      simple_str = str.gsub(' ',' OR ')
      return self.search(simple_str, {:conditions => (active_only ? "is_active = #{true} and created_at <= '#{Time.sl_local_db}'" : nil), :limit => limit})
    end
	end
	def self.find_by_string_full(str, limit = Preference.get_setting('SEARCH_RESULTS_FULL'))
	  return self.find_by_string(str, limit, true)
  end
  
  # find posts based sql (for use in views via a helper)
  def self.find_flexible(sql)
    self.find_by_sql(sql)
  end
  
  # get a list of tags that are assigned more than once and sorts them by name ascending
  def self.get_tags
    self.tags_count(:count => '> 0', :current_only => true, :order => 'name asc')
  end

end