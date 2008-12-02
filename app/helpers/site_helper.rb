# $Id: site_helper.rb 314 2007-02-06 16:40:47Z garrett $

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

class Site

  #
  # extends the Prefs model by adding an easy way to refer to preferences
  # with the Site.pref_name nomenclature as well as acting as a pseudo-helper
  # so you can call methods such as Site.get_author_gender
  #
  
  #
  # meta tags
  #
  
  # quick way to create a meta tag, shared by other helpers
  def self.simple_meta_tag(name, val)
    return '<meta name="' + name + '" content="' + val + '"/>'
  end
  
  # default chunk of meta tags for author, description, title
  def self.default_meta_tags
    block  = '<meta http-equiv="content-type" content="text/html; charset=' + Preference.get_setting('encoding') + '"/>' + "\n\t"
    block += '<meta name="author" content="' + Preference.get_setting('site_primary_author') + '"/>' + "\n\t"
		block += '<meta name="description" content="' + Comment.kill_tags(Preference.get_setting('site_description')) + '"/>' + "\n\t"
		block += '<meta name="dc.title" content="' + Preference.get_setting('site_name') + '"/>' + "\n\t"
		block += '<link rel="start" href="' + self.full_url + '" title="' + Preference.get_setting('site_name') + '"/>'
		return block
  end
  
  # various identifer meta tags
  def self.icbm_meta_tag
    icbm = Preference.get_setting('icbm')
    return (icbm != '' ? self.simple_meta_tag('icbm', icbm) : '')
  end
  def self.esbn_meta_tag
    esbn = Preference.get_setting('esbn')
    return (esbn != '' ? self.simple_meta_tag('esbn', esbn) : '')
  end
  def self.issn_meta_tag
    issn = Preference.get_setting('issn')
    return (issn != '' ? self.simple_meta_tag('issn', issn) : '')
  end
  
  #
  # blocks
  #
  
  # a list of all the active tags (1 or more post assigned)
  def self.list_tags_linked(tags, div_id = 'tags', title = 'Tags', archive_token = Preference.get_setting('archive_token'), separator = ', ')
    # start the output
    list  = (div_id != '' ? '<div id="' + div_id + '">' : '')
	  list += (title != '' ? '<b>' + title + ':</b> ' : '')
    if tags.length == 0
    # no tags
      list += "There aren't any tags yet."
    else
    # we've got some tags
      c = 0
      for tag in tags.sort
      # build the list
        list += (c > 0 ? separator : '') + "<a href=\"#{self.full_url}/#{archive_token}/tags/#{tag[0]}\" title=\"View posts tagged with &quot;#{tag[0]}&quot;\">#{tag[0]}</a>"
        c = c+1
      end
    end
    # all done
    return list + (div_id != '' ? '</div>' : '')
  end
  
  # a list of all active authors (1 or more post written)
  def self.list_authors_linked(authors, div_id = 'authors', title = 'Authors', archive_token = Preference.get_setting('archive_token'), separator = ', ')
    if Preference.get_setting('SHOW_AUTHOR_OF_POST') == 'yes' and authors
    # we only do this is the preference is set as such
      # start the output
      list  = '<div id="' + div_id + '">'
      list += (title != '' ? '<b>' + title + ':</b> ' : '')
      if authors.length == 0
      # no authors
        list += "There aren't any authors yet."
      else
      # we've got authors
        c = 0
        for author in authors
        # build the list
          list += (c > 0 ? separator : '') + "<a href=\"#{self.full_url}/#{archive_token}/authors/#{author.id.to_s}\" title=\"View all posts by #{author.name}\">#{author.name}</a>"
          c = c+1
        end
      end
      # all done
      return list + '</div>'
    end
  end
  
  # build a structured list of archive items
  def self.archives_structure_linked(posts, start_header_level = 3, use_li = false)
    cy = 0
    cm = 0
    closed_y = true
    closed_m = true
    keep_month = ''
    keep_year = ''
    
    ot  = (use_li ? '<ul>' : '<dt>')
    otc = (use_li ? '</ul>' : '</dt>')
    it  = (use_li ? '<li>' : '<dd>')
    itc = (use_li ? '</li>' : '</dd>')
    
    output = ''
    for p in posts
      if keep_year != p.created_at.year
        if cy != 0
          output << otc
          closed_y = true
          cy = 0
        end
        output << "#{ot}#{it}<h#{start_header_level}>#{p.created_at.year}</h#{start_header_level}>#{itc}"
        closed_y = false
      end
      if keep_month != p.created_at.month
        if cm != 0
          output << otc
          closed_m = true
          cm = 0
        end
        output << "#{ot}#{it}<h#{(start_header_level+1)}><a href=\"#{self.full_url}/#{Preference.get_setting('archive_token')}/#{p.created_at.strftime('%Y/%m')}\" title=\"#{p.created_at.strftime('%B')}\">#{p.created_at.strftime('%B')}</a></h#{(start_header_level+1)}>#{itc}"
        closed_m = false
      end
      output << "#{it}<a href=\"#{Post.permalink(p)}\" title=\"#{p.title}\">#{p.title}</a>#{itc}"

      keep_month = p.created_at.month
      keep_year = p.created_at.year
      cy += 1
      cm += 1
    end
    return output + (!closed_y ? otc : '') + (!closed_m ? otc : '')
  end
    
  # grab any posts using SQL
  def self.get_posts(sql = "select * from posts where is_active = true order by created_at desc")
    return Post.find_flexible(sql)
  end
  
  #
  # html/css/javascript-related
  #
  
  # body id for use in CSS overriding (returns something like yoursite-com)
  def self.body_id
    bid = Preference.get_setting('domain').gsub('.', '-')
    return (bid != '' ? " id=\"#{bid}\"" : '')
  end
  
  # if they're using mint, this creates a block to reference the jscript file
  def self.mint_tag
    mint_dir = Preference.get_setting('mint_dir')
    return (mint_dir != '' ? "<!-- mint tag -->\n" + '<script src="' + mint_dir + (mint_dir[-1..mint_dir.length] == '/' ? '' : '/') + '?js" type="text/javascript"></script>' + "\n<!-- end mint tag -->" : '')
  end
  
  # a link to the site with the site's name as the link text
  def self.site_name_linked
    name = Preference.get_setting('site_name')
    return '<a href="' + (self.full_url == '' ? '/' : self.full_url) + '" title="' + name + '">' + name + '</a>'
  end
  
  # link to the posts RSS feed
  def self.rss_feed_link(name = 'full-text RSS feed', title = 'Full-text RSS feed')
    return "<a href=\"#{self.rss_url}\" title=\"#{title}\">#{name}</a>"
  end
  
  # link to the comments RSS feed
  def self.comments_feed_link(name = 'comments RSS feed', title = 'Comments RSS feed')
    return "<a href=\"#{self.comments_rss_url}\" title=\"#{title}\">#{name}</a>"
  end
  
  # show link to delicious bookmarks and RSS feed
  def self.delicious_info(wrap_in_p = true)
    del_user = Preference.get_setting('delicious_username')
    if del_user != ''
      return (wrap_in_p ? '<p>' : '') + "Interesting links can be found at <a href=\"http://del.icio.us/#{del_user}\" title=\"del.icio.us\">del.icio.us</a> or by subscribing to my <a href=\"http://del.icio.us/rss/#{del_user}\" title=\"My del.icio.us feed\">del.icio.us feed</a>" + (wrap_in_p ? '</p>' : '')
    else
      return ''
    end
  end
  
  # create a link to a 'static' page
  def self.link_to_page(link)
    return Site.full_url + '/pages/' + link.to_s
  end
  
  # create a full URL for post permalinks (references the Post method)
  def self.permalink(post)
    return Post.permalink(post, archive_token = Preference.get_setting('ARCHIVE_TOKEN'))
  end
  
  #
  # various outputted texts
  #

  # when this site was copyrighted-present (if later)
  def self.copyright_range
    copy_year = Preference.get_setting('copyright_year')
    return copy_year + (Time.sl_local.year.to_s != copy_year ? '-' + Time.sl_local.year.to_s : '')
  end

  # powered by link
  def self.powered_by_link
    return 'Powered by <a href="http://simplelog.net" title="A simple Ruby on Rails weblog application">SimpleLog</a>'
  end
  
  # he, she, him, her, i dunno... this is somewhat pointless, isn't it?
  def self.primary_author_pronoun
    return (Preference.get_setting('author_gender') == 'male' ? 'him' : 'her')
  end
  
  #
  # global values (urls, comments)
  #
  
  # grab the full URL of the site
  def self.full_url
    # get the pref value
    url = Preference.get_setting('domain')
    return (url != '' ? 'http://' + url : '')
  end
  
  # grab the REAL URL of the site, based on requests, and test it against
  # the domain set in preferences... if the domain in preferences sounds
  # local and differs from the real one, then let's not trust it and
  # warn the user
  def self.check_for_local_domain(url)
    # disabling this for now until we need it in the future...
    return false
    # check for nils, just in case
    #url = '' if url == nil
    ## grab the subdomains
    #subtld = (@@app_req.subdomains ? @@app_req.subdomains.join('.') : '')
    ## build the full url
    #real_url = (subtld != '' ? subtld + '.' : '') + (@@app_req.domain ? @@app_req.domain : '')
    ## now let's check the two
    #if url =~ /(localhost[\:0-9]?)|([127|0]\.0\.0\.[0|1][\:0-9]?)/
    ## we might be local
    #  if real_url != url
    #    return 'http://' + real_url
    #  end
    #end
    #return false
  end
  
  # grab the full RSS URL for the site
  def self.rss_url
    url = Preference.get_setting('rss_url')
    return (url != '' ? 'http://' + url : self.full_url + '/rss')
  end
  
  # same as above, but for comments
  def self.comments_rss_url
    return self.full_url + '/comments/rss'
  end
  
  # powered by HTML comment
  def self.powered_by_comment
    return "<!--\n\t\tThis weblog is powered by SimpleLog, a simple Ruby on Rails\n\t\tweblog application available at http://simplelog.net\n-->\n"
  end
  
  # version number HTML comment
  def self.version_number_comment
    return "<!--\n\t\tSimpleLog version #{SL_CONFIG[:VERSION]}\n-->\n"
  end
  
  #
  # utilities for finding your current location
  #
  
  # return a string telling the user what the current action is
  # this can be compared against: if Site.whereami == 'index' etc
  def self.whereami
    if @@app_params[:controller] == 'page'
      if @@app_params[:action] == 'show'
        'pages/' + @@app_params[:link]
      else
        'index'
      end
    elsif @@app_params[:controller] == 'post'
      case @@app_params[:action]
        when 'archives_list'
          'archives/list'
        when 'by_author'
          'archives/by_author'
        when 'by_day'
          'archives/daily'
        when 'by_month'
          'archives/monthly'
        when 'by_year'
          'archives/yearly'
        when 'feed_all_rss'
          'feeds/posts'
        when 'feed_comments_rss'
          'feeds/comments'
        when 'list'
          'index'
        when 'search'
          'search/results'
        when 'search_full'
          'search/full_results'
        when 'show'
          'posts/show'
        when 'tagged'
          'archives/by_tag'
        when 'tags_list'
          'archives/list_tags'
        else
          'index'
      end
    else
      case @@app_params[:action]
      when 'handle_unknown_request'
        'errors/unknown_request'
      else
        'index'
      end
    end
  end
  # another way to get Site.whereami
  def self.current_location
    self.whereami
  end
  
  # boolean check against the current page
  # if Site.page_is(index), etc
  def self.page_is(str)
    return (self.whereami == str)
  end
  
  # some boolean-returning common location checks
  def self.is_home_page
    return (self.whereami == 'index')
  end
  def self.is_archives
    case self.whereami
      when 'archives/list'
        true
      when 'archives/by_author'
        true
      when 'archives/daily'
        true
      when 'archives/monthly'
        true
      when 'archives/yearly'
        true
      when 'archives/by_tag'
        true
      when 'archives/list_tags'
        true
      when 'posts/show'
        true
      else
        false
    end
  end
  def self.is_search
    return ((self.whereami == 'search/results') or (self.whereami == 'search/full_results'))
  end
  def self.is_static_page
    return (@@app_params[:controller] == 'page' and @@app_params[:action] == 'show')
  end
  
  #
  # common preference booleans
  #
  
  # do we show author info?
  def self.show_authors
    return (Preference.get_setting('show_author_of_post') == 'yes' ? true : false)
  end
  
  # is the comment system turned on?
  def self.comment_system_on
    return (Preference.get_setting('commenting_on') == 'yes' ? true : false)
  end
  
  # is gravatar support turned on?
  def self.gravatars_on
    return (Preference.get_setting('show_gravatars') == 'yes' ? true : false)
  end
  
  # are we allowing comment subjects?
  def self.allow_comment_subjects
    return (Preference.get_setting('comment_subjects') == 'yes' ? true : false)
  end
  
  #
  # handle getting prefs by pseudo method names and
  # receiving useful data from other classes/helpers
  # DO NOT CHANGE THESE METHODS
  #
  
  # grab the passed id and use it to select the pref
  def self.method_missing(id)
    return Preference.get_setting(id.id2name)
  end

  # get the params from the app
  def self.get_params_and_req(app_params, req)
    @@app_params = app_params
    @@app_req = req
  end

end

module SiteHelper

  # we need to initialize this so that rails doesn't freak out, but
  # we're not going to use it because we want people to specify the 
  # Site class when using these helper methods (see above)
  
end