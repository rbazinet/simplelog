# $Id: blogger_service.rb 300 2007-02-01 23:01:00Z garrett $

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
# blogger api
#

module BloggerStructs
  
  class Blog < ActionWebService::Struct
    member :url, :string
    member :blogid, :string
    member :blogName, :string
  end
  
  class User < ActionWebService::Struct
    member :email, :string
    member :firstname, :string
    member :nickname, :string
    member :userid, :string
    member :url, :string
    member :lastname, :string
  end
  
end

class BloggerApi < ActionWebService::API::Base
  
  inflect_names false
  
  api_method :getUsersBlogs,
    :expects => [{:appkey => :string}, {:username => :string}, {:password => :string}],
    :returns => [[BloggerStructs::Blog]]
    
  api_method :deletePost,
    :expects => [{:appkey => :string}, {:postid => :int}, {:username => :string}, {:password => :string}, {:publish => :bool}],
    :returns => [:bool]
    
  api_method :getUserInfo,
    :expects => [{:appkey => :string}, {:username => :string}, {:password => :string}],
    :returns => [BloggerStructs::User]
  
end

class BloggerService < SimplelogWebService
  
  web_service_api BloggerApi
  
  before_invocation :authorize
  
  def getUsersBlogs(appkey, username, password)
    [
      BloggerStructs::Blog.new(
        :url => 'http://' + Preference.get_setting('DOMAIN'),
        :blogid => 1,
        :blogName => Preference.get_setting('SITE_NAME')
      )
    ]
  end
  
  def deletePost(appkey, postid, username, password, publish)
    post = Post.find(postid)
    if post.destroy
      return true
    else
      return false
    end
  end
  
  def getUserInfo(appkey, username, password)
    author = Author.authorize(username, password, true, true)
    BloggerStructs::User.new(
      :email => author.email,
      :firstname => author.name,
      :nickname => author.name,
      :userid => author.id.to_s,
      :url => author.url || '',
      :lastname => ''
    )
  end

end