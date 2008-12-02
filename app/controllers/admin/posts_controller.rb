# $Id: posts_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::PostsController < Admin::BaseController
  
	#
	# posts, we love you, you are the bulk of our app
	#
	
	# get a list of posts, paginated, with sorting
	def post_list
	  # grab the sorter
		if Preference.get_setting('COMMENTING_ON') == 'yes'
		# comments are turned on, we need to include that in sorting
		  @sorter = SortingHelper::Sorter.new self, %w(created_at title is_active comments_count), params[:sort], (params[:order] ? params[:order] : 'DESC'), 'created_at', 'ASC'
		else
		# comments are off
		  @sorter = SortingHelper::Sorter.new self, %w(created_at title is_active), params[:sort], (params[:order] ? params[:order] : 'DESC'), 'created_at', 'ASC'
	  end
		# grab the paginator
    @post_pages = Paginator.new self, Post.count, 20, params[:page]
    if Preference.get_setting('COMMENTING_ON') == 'yes'
    # grab the posts (join on comments for count)
		  @posts = Post.find(:all, :select => 'posts.id, posts.created_at, posts.title, posts.body, posts.is_active, COUNT(comments.id) as comments_count', :joins => 'left outer join comments on comments.post_id = posts.id', :group => 'posts.id, posts.title, posts.body, posts.is_active, posts.created_at', :order => @sorter.to_sql, :limit => @post_pages.items_per_page, :offset => @post_pages.current.offset)
		else
    # grab the posts (no comments)
		  @posts = Post.find(:all, :order => @sorter.to_sql, :limit => @post_pages.items_per_page, :offset => @post_pages.current.offset)
		end
		$admin_page_title = 'Listing posts'
		render :template => 'admin/posts/post_list'
	end

  # create a new post
	def post_new
		@post     = Post.new
		@tags     = Tag.find(:all, :order => 'name asc')
		@authors  = Author.find(:all, :order => 'name asc')
		$admin_page_title = 'New post'
		@onload   = "document.forms['post_form'].elements['post[title]'].focus()"
		render :template => 'admin/posts/post_new'
	end

  # save a new post
	def post_create
	  # let's create our new post
		@post = Post.new(params[:post])
		# set custom fields to empty string if they're not set
		@post.custom_field_1 = @post.custom_field_1 || ''
		@post.custom_field_2 = @post.custom_field_2 || ''
		@post.custom_field_3 = @post.custom_field_3 || ''
		# assign our tags
		@post.tag((params[:tag_input] ? params[:tag_input].gsub("'", '').gsub(/[^a-zA-Z0-9 ]/, '') : ''), :clear => true)
		if @post.save
		# post was saved successfully
		  # do the ping if necessary
		  do_ping if params[:ping] == 1
			flash[:notice] = 'Post was created.'
			if Preference.get_setting('RETURN_TO_POST') == 'yes'
			# if they have a pref set as such, return them to the post,
			# rather than the list
			  redirect_to Site.full_url + '/admin/posts/edit/' + @post.id.to_s
			else
			  redirect_to Site.full_url + '/admin/posts'
		  end
		else
		# whoops!
		  @tags     = Tag.find(:all, :order => 'name asc')
		  @authors  = Author.find(:all, :order => 'name asc')
		  @preview  = (@post.body_raw ? @post.body_raw: '') + (@post.extended_raw ? @post.extended_raw : '')
		  # remember the update checking if it's there
		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'post_new', :template => 'admin/posts/post_new'
		end
	end

	# load the post we're editing
	def post_edit
		@post     = Post.find(params[:id])
		@plink    = Post.permalink(@post[0])
		@tags     = Tag.find(:all, :order => 'name asc')
		@authors  = Author.find(:all, :order => 'name asc')
		@preview  = (@post.body ? @post.body : '') + (@post.extended ? @post.extended : '')
		$admin_page_title = 'Editing post'
		@onload   = "document.forms['post_form'].elements['post[title]'].focus()"
		render :template => 'admin/posts/post_edit'
	end

  # update an existing post
	def post_update
	  # find our post
		@post = Post.find(params[:id])
		# set custom fields to empty string if they're not set
		@post.custom_field_1 = @post.custom_field_1 || ''
		@post.custom_field_2 = @post.custom_field_2 || ''
		@post.custom_field_3 = @post.custom_field_3 || ''
		# assign our tags (clearing old tags)
		@post.tag((params[:tag_input] ? params[:tag_input].gsub("'", '').gsub(/[^a-zA-Z0-9 ]/, '') : ''), :clear => true)
		if @post.update_attributes(params[:post])
		# post was updated successfully
			flash[:notice] = 'Post was updated.'
			if Preference.get_setting('RETURN_TO_POST') == 'yes'
			# if they have a pref set as such, return them to the post,
			# rather than the list
			  redirect_to Site.full_url + '/admin/posts/edit/' + @post.id.to_s
			else
			  redirect_to Site.full_url + '/admin/posts'
		  end
		else
		# whoops!
		  @tags     = Tag.find(:all, :order => 'name asc')
		  @authors  = Author.find(:all, :order => 'name asc')
		  @preview  = (@post.body_raw ? @post.body_raw: '') + (@post.extended_raw ? @post.extended_raw : '')
		  # remember the update checking if it's there
		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'post_edit', :template => 'admin/posts/post_edit'
		end
	end

	# destroy an existing post! destroy! destroy! destory!
	def post_destroy
		Post.find(params[:id]).destroy
		flash[:notice] = 'Post was destroyed.'
		if session[:was_searching]
		# they came from somewhere, let's send them back there
			session[:was_searching] = nil
			q = session[:prev_search_string]
			session[:prev_search_string] = nil
			redirect_to Site.full_url + '/admin/posts/search?q=' + q
		else
		# not sure where they came from, just send them to normal place
			redirect_to Site.full_url + '/admin/posts'
		end
	end
	
	# create a filter-passed preview of the post, checking for malformed XHTML
	def post_preview
	  # add the body if we've got it
	  body = '' + (check_for_bad_xhtml(params[:post][:body_raw], 'post', params[:post][:text_filter]) if params[:post][:body_raw])
	  # add the extended bits if we've got them
	  extd = '' + (check_for_bad_xhtml(params[:post][:extended_raw], 'post', params[:post][:text_filter]) if params[:post][:extended_raw])
	  # dump it out
	  render :text => body + extd, :layout => false
  end
  
  # search for posts
  def post_search
    session[:was_searching] = 1
    session[:prev_search_string] = params[:q]
    @posts = Post.find_by_string(params[:q], 20, false)
    $admin_page_title = 'Search results'
    render :template => 'admin/posts/post_search'
  end
  
  # batch processing for comment settings
  def post_batch_comments
    if params[:comment_batch][:timeframe] and params[:comment_batch][:setting]
      timeframe = params[:comment_batch][:timeframe].to_i
      setting = params[:comment_batch][:setting].to_i
      if timeframe == 0
      # all posts
        posts = Post.find(:all)
      else
      # let's build the date for the timeframe
        today = Time.sl_local
        backdate = (Time.sl_local-(86400*timeframe))
        posts = Post.find(:all, :conditions => ['created_at >= ?', backdate])
      end
      for p in posts
      # let's set the comment status appropriately
        p.update_attribute('comment_status', setting)
      end
      # all done!
      flash[:notice] = 'Batch processing completed.'
      redirect_to Site.full_url + '/admin/posts'
    else
    # don't know what happened, but we didn't get the required
    # stuff so let's send them back
      redirect_to Site.full_url + '/admin/posts'
    end
  end
  
end