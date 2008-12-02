# $Id: tags_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::TagsController < Admin::BaseController
  
  #
  # tags keep everything nice and organized (somewhat)
  #
  
  # strips quotes, spaces, special chars from tags
  def clean_tag(input)
    input = input.gsub(' ', '').gsub("'", '').gsub(/[^a-zA-Z0-9 ]/, '')
    return input
  end
  
  # get a list of tags, paginated, with sorting
	def tag_list
	  # grab the sorter
		@sorter = SortingHelper::Sorter.new self, %w(name post_count), params[:sort], params[:order], 'name', 'ASC'
		# grab the paginator
    @tag_pages = Paginator.new self, Tag.count, 20, params[:page]
    # grab the tags and get posts counts as well for sorting
		@tags = Tag.find(:all, :select => 'tags.id, tags.name, count(tags_posts.tag_id) as post_count', :joins => 'left outer join tags_posts on tags.id = tags_posts.tag_id', :group => 'tags.id, tags.name', :order => @sorter.to_sql, :limit => @tag_pages.items_per_page, :offset =>  @tag_pages.current.offset)
		$admin_page_title = 'Listing tags'
		render :template => 'admin/tags/tag_list'
	end
	
	# show posts tagged with this tag
	def tag_show
	  @tag = Tag.find(params[:id])
	  @posts = Post.find_by_tag(@tag.name, false)
	  $admin_page_title = 'Showing posts tagged with "' + @tag.name + '"'
	  render :template => 'admin/tags/tag_show'
  end

  # create a new tag
	def tag_new
		@tag = Tag.new
		$admin_page_title = 'New tag'
		@onload = "document.forms['tag_form'].elements['tag[name]'].focus()"
		render :template => 'admin/tags/tag_new'
	end
	
	# save a new tag (no spaces)
	def tag_create
	  # let's create our new tag
		@tag = Tag.new(params[:tag])
		@tag.name = clean_tag(@tag.name)
		if @tag.save
		# tag was saved successfully
			flash[:notice] = 'Tag was created.'
			redirect_to Site.full_url + '/admin/tags'
		else
		# whoops!
		  # remember the update checking if it's there
	    @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'tag_new', :template => 'admin/tags/tag_new'
		end
	end

	# load the tag we're editing
	def tag_edit
		@tag = Tag.find(params[:id])
		@posts = Post.find_by_tag(@tag.name, false)
		@old_name = @tag.name
		$admin_page_title = 'Editing tag'
		@onload = "document.forms['tag_form'].elements['tag[name]'].focus()"
		render :template => 'admin/tags/tag_edit'
	end

  # update an existing tag
  # first we have to see if this tag has the same name as another, because if
  # it does, we're going to merge the two tags together with the name inputted.
  # so if someone has two tags: (1) red (2) blue and they go into red and change
  # its name to blue, we'll take all the posts tagged with red and tag them blue
  # and then delete the red tag.
	def tag_update
    # let's check for a dup and merge if necessary
		@tags = Tag.find(:all)
		@temp = Tag.new(params[:tag])
		@temp.name = clean_tag(@temp.name) if @temp.name # strip spaces and quotes
    dup = false
    for tag in @tags
      if @temp.name == tag.name and tag.name != params[:old_name]
      # we found a duplicate
        dup = true
        break
      end
    end
    if dup
    # there was a duplicate--re-tag all the posts with the old tag to the new
    # one and then delete the old one
      @posts = Post.find_by_tag(params[:old_name])
      for post in @posts
        post.tag(@temp.name)
      end
      # kill the old tag
      @tag = Tag.find(:all, :conditions => ['name = ?', params[:old_name]])
      @tag[0].destroy
      flash[:notice] = 'Tags were merged.'
      redirect_to Site.full_url + '/admin/tags'
    else
    # no duplicate, this is just a straight rename
      # find our tag
  		@tag = Tag.find(params[:id])
  		if @tag.update_attributes(:name => clean_tag(params[:tag]['name']))
  		# tag was updated successfully
  			flash[:notice] = 'Tag was updated.'
  			redirect_to Site.full_url + '/admin/tags'
  		else
  		# whoops!
  		  @old_name = params[:old_name]
  		  @posts = Post.find_by_tag(params[:old_name], false)
  		  # remember the update checking if it's there
  		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
  			render :action => 'tag_edit', :template => 'admin/tags/tag_edit'
  		end
  	end
	end

  # destroy an existing tag! destroy! destroy! destory!
	def tag_destroy
		Tag.find(params[:id]).destroy
		flash[:notice] = 'Tag was destroyed.'
		if session[:was_searching]
		# they came from somewhere, let's send them back there
			session[:was_searching] = nil
			q = session[:prev_search_string]
			session[:prev_search_string] = nil
			redirect_to Site.full_url + '/admin/tags/search?q=' + q
		else
		# not sure where they came from, just send them to normal place
			redirect_to Site.full_url + '/admin/tags'
		end
	end
	
	# search for tags
  def tag_search
    session[:was_searching] = 1
    session[:prev_search_string] = params[:q]
    @tags = Tag.find_by_string(params[:q], 20)
    $admin_page_title = 'Search results'
    render :template => 'admin/tags/tag_search'
  end
  
end