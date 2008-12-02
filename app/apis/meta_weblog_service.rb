# $Id: meta_weblog_service.rb 313 2007-02-06 16:37:40Z garrett $

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
# meta weblog api
#

module MetaWeblogStructs
  
  class Blog < ActionWebService::Struct
    member :url, :string
    member :blogid, :string
    member :blogName, :string
  end
  
  class Post < ActionWebService::Struct
    member :dateCreated, :time
    member :userid, :string
    member :postid, :string
    member :description, :string
    member :title, :string
    member :link, :string
    member :permaLink, :string
    member :mt_excerpt, :string
    member :mt_text_more, :string
    member :mt_allow_comments, :int
    member :mt_allow_pings, :int
    member :mt_convert_breaks, :string
    member :mt_keywords, :string
  end
  
end

class MetaWeblogApi < ActionWebService::API::Base

  inflect_names false
  
  api_method :getRecentPosts,
    :expects => [{:blogid => :string}, {:username => :string}, {:password => :string}, {:numberOfPosts => :int}],
    :returns => [[MetaWeblogStructs::Post]]
    
  api_method :newPost,
    :expects => [
                {:blogid => :string},
                {:username => :string},
                {:password => :string},
                {:content => MetaWeblogStructs::Post},
                {:publish => :bool}
                ],
    :returns => [:string]
    
  api_method :editPost,
    :expects => [
                {:postid => :string},
                {:username => :string},
                {:password => :string},
                {:content => MetaWeblogStructs::Post},
                {:publish => :bool}
                ],
    :returns => [:bool]
    
  api_method :getPost,
    :expects => [{:postid => :string}, {:username => :string}, {:password => :string}],
    :returns => [MetaWeblogStructs::Post]
    
  # this really doesn't belong here, but flickr thinks it does so we'll add it here too
  api_method :getUsersBlogs,
    :expects => [{:appkey => :string}, {:username => :string}, {:password => :string}],
    :returns => [[MetaWeblogStructs::Blog]]

end

class MetaWeblogService < SimplelogWebService
  
  web_service_api MetaWeblogApi
  
  before_invocation :authorize
  
  def getRecentPosts(blogid, username, password, numberOfPosts)
    Post.find(:all, :order => 'created_at desc', :limit => numberOfPosts).collect do |p|
      struct_post(p)
    end
  end
  
  def struct_post(p)
    MetaWeblogStructs::Post.new(
      :dateCreated => p.created_at.iso8601 || '',
      :userid => 1,
      :postid => p.id.to_s,
      :description => p.body_raw,
      :title => p.title,
      :link => 'http://' + Preference.get_setting('DOMAIN') + Post.permalink(p),
      :permaLink => 'http://' + Preference.get_setting('DOMAIN') + Post.permalink(p),
      :mt_excerpt => p.summary || '',
      :mt_text_more => p.extended_raw || '',
      :mt_allow_comments => p.comment_status,
      :mt_allow_pings => 0,
      :mt_convert_breaks => p.text_filter,
      :mt_keywords => ''
    )
  end
  
  def newPost(blogid, username, password, content, publish)
    # we have to do this sort of manually, because we need to return the right errors
    # in the proper cases... if we let rails do it using the method, it will simply
    # return some redirect errors and such... can't have that... ugh...
    author = Author.authorize(username, password, true, true)
    p = Post.new
    p.created_at = Time.sl_local
    p.modified_at = Time.sl_local
    p.title = ((content['title'] and content['title'] != '') ? content['title'] : 'Untitled')
    p.permalink = Post.to_permalink((Preference.get_setting('SIMPLE_TITLES') == 'yes' ? content['description'] : p.title))
    p.body_raw = content['description'] || ''
    p.body = (Post.create_clean_content(content['description']) if content['description']) || ''
    p.synd_title = (Preference.get_setting('SIMPLE_TITLES') ? Post.to_synd_title(p.body) : p.title)
    p.is_active = publish
    p.author_id = author.id
    p.extended_raw = content['mt_text_more'] || ''
    p.extended = (Post.create_clean_content(content['mt_text_more']) if content['mt_text_more']) || ''
    p.summary = content['mt_excerpt'] || ''
    p.text_filter = ((content['mt_convert_breaks'] == '0' or content['mt_convert_breaks'] == '' or !content['mt_convert_breaks']) ? Preference.get_setting('TEXT_FILTER') : content['mt_convert_breaks']);
    p.comment_status = ((content['mt_allow_comments'] == '0' or content['mt_allow_comments'] == '' or !content['mt_allow_comments']) ? 0 : content['mt_allow_comments'])
    p.custom_field_1 = p.custom_field_1 || ''
    p.custom_field_2 = p.custom_field_2 || ''
    p.custom_field_3 = p.custom_field_3 || ''
    if p.save
      return p.id.to_s
    else
      return 'Error: Post could not be created!'
    end
  end
  
  def editPost(postid, username, password, content, publish)
    author = Author.authorize(username, password, true, true)
    p = Post.find(postid)
    p.modified_at = Time.sl_local
    p.title = ((content['title'] and content['title'] != '') ? content['title'] : 'Untitled')
    p.permalink = Post.to_permalink((Preference.get_setting('SIMPLE_TITLES') == 'yes' ? content['description'] : p.title))
    p.body_raw = content['description'] || ''
    p.body = (Post.create_clean_content(content['description']) if content['description']) || ''
    p.synd_title = (Preference.get_setting('SIMPLE_TITLES') ? Post.to_synd_title(p.body) : p.title)
    p.is_active = publish
    p.author_id = author.id
    p.extended_raw = content['mt_text_more'] || ''
    p.extended = (Post.create_clean_content(content['mt_text_more']) if content['mt_text_more']) || ''
    p.summary = content['mt_excerpt'] || ''
    p.text_filter = ((content['mt_convert_breaks'] == '0' or content['mt_convert_breaks'] == '' or !content['mt_convert_breaks']) ? Preference.get_setting('TEXT_FILTER') : content['mt_convert_breaks']);
    p.comment_status = ((content['mt_allow_comments'] == '0' or content['mt_allow_comments'] == '' or !content['mt_allow_comments']) ? 0 : content['mt_allow_comments'])
    p.custom_field_1 = p.custom_field_1 || ''
    p.custom_field_2 = p.custom_field_2 || ''
    p.custom_field_3 = p.custom_field_3 || ''
    if p.save
      return true
    else
      return false
    end
  end
  
  def getPost(postid, username, password)
    post = Post.find(postid)
    struct_post(post)
  end
  
  def getUsersBlogs(appkey, username, password)
    [
      MetaWeblogStructs::Blog.new(
        :url => 'http://' + Preference.get_setting('DOMAIN'),
        :blogid => 1,
        :blogName => Preference.get_setting('SITE_NAME')
      )
    ]
  end
  
end