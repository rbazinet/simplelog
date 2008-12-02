# $Id: application_helper.rb 300 2007-02-01 23:01:00Z garrett $

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

module ApplicationHelper
  
  # global access to the db-based preferences settings
  def get_pref(name)
    return Preference.get_setting(name)
  end
    
  # check which browser the author is using and get ready to warn if it's a crappy one
  def check_browser
		@bad_browser = false
		agent = request.env['HTTP_USER_AGENT']
		if (agent =~ /windows/i) and (agent =~ /msie/i)
		  @bad_browser = true
			if (agent =~ /opera/i)
				@is_opera = true
			end
		end
	end
	
	# uses the enkoder plugin to create a safe email link
	def create_enkoded_email(
	                        email = get_pref('AUTHOR_EMAIL'),
	                        link_text = ('send ' + (get_pref('AUTHOR_GENDER') == 'male' ? 'him' : 'her') + ' an email'),
	                        link_title = ('Send ' + get_pref('SITE_PRIMARY_AUTHOR') + ' an email'),
	                        subject = get_pref('EMAIL_SUBJECT')
	                        )
     return enkode_mail(email, link_text, link_title, subject).rstrip
	end
	
	# build a list of all tags for the about site section
	#### DEPRECATED: See site_helper.rb -> list_tags_linked
	def build_tag_block(tags, title = 'Tags', archive_token = get_pref('ARCHIVE_TOKEN'), separator = ', ')
	  logger.warn('DEPRECATED: The ApplicationHelper method build_tag_block() has been deprecated. Please use Site.list_tags_linked() instead.')
	  # start the output
	  list = (title != '' ? '<b>' + title + ':</b> ' : '')
    if tags.length == 0
    # no tags
      list += "There aren't any tags yet."
    else
    # we've got some tags
      c = 0
      for tag in tags.sort
      # build the list
        list += (c > 0 ? separator : '') + "<a href=\"/#{archive_token}/tags/#{tag[0]}\" title=\"View posts tagged with &quot;#{tag[0]}&quot;\">#{tag[0]}</a>"
        c = c+1
      end
    end
    # all done
    return list
	end
	
	# builds a list of tags for the tag archive
	def build_tag_archive_list(tags)
	  build_tag_block(tags, '')
  end
	
	# build a list of all active authors for the about site section
	#### DEPRECATED: See site_helper.rb -> list_authors_linked
	def build_author_block(authors, title = 'Authors', archive_token = get_pref('ARCHIVE_TOKEN'), separator = ', ')
    logger.warn('DEPRECATED: The ApplicationHelper method build_author_block() has been deprecated. Please use Site.list_authors_linked() instead.')
    # start the output
    list = (title != '' ? '<b>' + title + ':</b> ' : '')
    if authors.length == 0
    # no authors
      list += "There aren't any authors yet."
    else
    # we've got authors
      c = 0
      for author in authors
      # build the list
        list += (c > 0 ? separator : '') + "<a href=\"/#{archive_token}/authors/#{author.id.to_s}\" title=\"View all posts by #{author.name}\">#{author.name}</a>"
        c = c+1
      end
    end
    # all done
    return list
	end
	
	# creates checkbox field for preference based on boolean/current value
	def create_pref_bool(id, current_value, description = '')
	 output = '<input type="checkbox" name="' + id + '" id="' + id + '" value="yes"'
	 if current_value == 'yes'
	   output += ' checked="checked"'
	 end
	 output += '/><input type="hidden" name="' + id + '" value="no"/><label class="left" for="' + id + '">&nbsp;<span class="small gray">' + description + '</span></label>'
	 return output
	end
	
	# creates select menu for preference based on possible values/current value
	def create_pref_select(id, possible_values, current_value = nil, capitalize = true)
	  output = '<select name="' + id + '" id="' + id + '">'
	  for v in possible_values
	    output += '<option value="' + v + '"'
	    if current_value == v
	      output += ' selected="selected"'
      end
	    output += '>' + (capitalize ? v.capitalize : v) + '</option>'
    end
    return output + '</select>'
  end
  
  # creates a select menu for theme selector
  def create_pref_theme_select(id, possible_values, current_value = nil)
    output = '<select name="' + id + '" id="' + id + '">'
	  for v in possible_values
	    output += '<option value="' + v['value'] + '"'
	    if current_value == v['value']
	      output += ' selected="selected"'
      end
	    output += '>' + v['name'] + '</option>'
    end
    return output + '</select>'
  end
  
	# creates a select menu with time offset options (and selects the current value)
	def create_pref_offset_select(id, current_value = '0')
	  output = '<select name="' + id + '" id="' + id + '">'
	  time = Time.new()
    -12.upto(14) do |h|
      output += '<option value="' + h.to_s + '"'
      if h.to_s == current_value
        output += ' selected="selected"'
      end
      gm = (time+(h*60*60)).gmtime
      output += '>' + ((gm.strftime('%I:%M%p on %B %d')).gsub('AM', 'am')).gsub('PM', 'pm') + '</option>'
    end
    return output + '</select>'
	end
	
	# creates select options for an html select form element based on the collection
	def create_author_select_options(collection, current_id = nil, add_blank = true, id = 'id', name = 'name')
		if add_blank
			options = '<option value="">Select one...</option>'
		else
			options = ''
		end
		if collection
			for item in collection
				options += '<option value="' + item[id].to_s + '"'
				if ((current_id and author_finder(current_id)) or (current_id == 0 and collection.length < 2))
				  options += (((current_id == item[id]) or (collection.length < 2)) ? ' selected="selected"' : '')
				end
				options += '>' + item[name] + '</option>'
			end
		end
		return options
	end
	
	# creates select options for an html select form element based on the collection
	def create_filter_select_options(collection, current_id = nil)
		options = ''
		if collection
			for item in collection
				options += '<option value="' + item + '"'
				if current_id
				  options += (current_id == item ? ' selected="selected"' : '')
				end
				options += '>' + item.capitalize + '</option>'
			end
		end
		return options
  end
	
	# creates select menu for comment options
	def create_comment_select(id, possible_values, current_value = nil)
	  output = '<select name="' + id + '" id="' + id + '">'
	  possible_values.each do |key, value|
	    output += '<option value="' + key.to_s + '"'
  	  if current_value == key
  	    output += ' selected="selected"'
      end
  	  output += '>' + value + '</option>'
    end
    return output + '</select>'
	  #for v in possible_values
	  #  output += '<option value="' + v['value'] + '"'
	  #  if current_value == v['value']
	  #    output += ' selected="selected"'
    #  end
	  #  output += '>' + v['name'] + '</option>'
    #end
    #return output + '</select>'
  end
	
	# gets the time with preference-set offset
	def get_offset_time(stamp = Time.now)
	  return (stamp+(get_pref('OFFSET').to_i*60*60)).getgm
	end
	
	# find author by id
	def author_finder(id)
	  return Author.find(:first, :conditions => ['id = ?', id])
  end
  
  # get author id from email
  def get_author_id(email)
    return Author.find(:first, :conditions => ['email = ?', email]).id
  rescue
    return nil
  end

  # create a gravatar image url
  def get_gravatar_url(email = '', size = '40', rating = 'PG')
    # build the url
    url  = 'http://www.gravatar.com/avatar.php?gravatar_id=' + Digest::MD5.hexdigest(email)
    url += "&amp;size=#{size}"
    url += "&amp;rating=#{rating}"
    # all done!
    return url
  end
  
end