# $Id: movable_type_service.rb 300 2007-02-01 23:01:00Z garrett $

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
# movable type api
#

module MovableTypeStructs

  class PostCategory < ActionWebService::Struct
    member :categoryName, :string
    member :categoryId, :string
    member :isPrimary, :bool
  end
  
  class Category < ActionWebService::Struct
    member :categoryId, :string
    member :categoryName, :string
  end
  
  class TextFilter < ActionWebService::Struct
    member :key, :string
    member :label, :string
  end

end

class MovableTypeApi < ActionWebService::API::Base
  
  inflect_names false
  
  api_method :getPostCategories,
    :expects => [{:postid => :string}, {:username => :string}, {:password => :string}],
    :returns => [[MovableTypeStructs::PostCategory]]
    
  api_method :getCategoryList,
    :expects => [{:blogid => :string}, {:username => :string}, {:password => :string}],
    :returns => [[MovableTypeStructs::Category]]
    
  api_method :supportedTextFilters,
    :returns => [[MovableTypeStructs::TextFilter]]
    
  api_method :setPostCategories,
    :expects => [
                {:postid => :string},
                {:username => :string},
                {:password => :string},
                {:categories => [MovableTypeStructs::PostCategory]}
                ],
    :returns => [:bool]
  
  api_method :publishPost,
    :expects => [{:postid => :string}, {:username => :string}, {:password => :string}],
    :returns => [:bool]
  
end

class MovableTypeService < SimplelogWebService
  
  web_service_api MovableTypeApi
  
  before_invocation :authorize, :except => [:getTrackbackPings, :supportedMethods, :supportedTextFilters]
  
  def getPostCategories(postid, username, password)
    Post.find(postid).tag_names.sort!.collect do |t|
      MovableTypeStructs::PostCategory.new(
        :categoryName => t,
        :categoryId => t,
        :isPrimary => false
      )
    end
  end
  
  def getCategoryList(blogid, username, password)
    Tag.find(:all, :order => 'name asc').collect do |t|
      MovableTypeStructs::Category.new(
        :categoryId => t.name,
        :categoryName => t.name
      )
    end
  end
  
  def supportedTextFilters
    filters = []
    filters << MovableTypeStructs::TextFilter.new(
      :key => 'markdown',
      :label => 'Markdown'
    )
    filters << MovableTypeStructs::TextFilter.new(
      :key => 'textile',
      :label => 'Textile'
    )
    filters << MovableTypeStructs::TextFilter.new(
      :key => 'convert line breaks',
      :label => 'Convert line breaks'
    )
    filters << MovableTypeStructs::TextFilter.new(
      :key => 'plain text',
      :label => 'Plain text'
    )
    return filters
  end
  
  def setPostCategories(postid, username, password, categories)
    post = Post.find(postid)
    if categories
      cats = ''
      for c in categories
        cats += (cats != '' ? ' ' : '') + (((c['categoryName'] == '' or !c['categoryName']) and c['categoryId'] != '') ? c['categoryId'] : c['categoryName'])
      end
      post.tag(cats, :clear => true)
    else
      post.tag('', :clear => true)
    end
    return true
  end
  
  def publishPost(postid, username, password)
    post = Post.find(postid)
    post.is_active = true
    post.save
  end
    
end