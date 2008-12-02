# $Id: comments_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::CommentsController < Admin::BaseController
  
  #
  # keep tabs on comments, approve them, modify them, go nuts
  #
    
  # get a list of comments, paginated, with sorting
	def comment_list
		# grab the sorter
		@sorter = SortingHelper::Sorter.new self, %w(created_at name title is_approved), params[:sort], (params[:order] ? params[:order] : 'DESC'), 'created_at', 'ASC'
		# grab the paginator
    @comment_pages = Paginator.new self, Comment.count, 20, params[:page]
    # grab the comments (join on posts for titles)
		@comments = Comment.find(:all, :select => 'comments.*, posts.title', :joins => 'left outer join posts on comments.post_id = posts.id', :order => @sorter.to_sql, :limit => @comment_pages.current.to_sql)
		$admin_page_title = 'Listing comments'
		render :template => 'admin/comments/comment_list'
	end
	
	# get a list of comments by the post they're associated with
  def comments_by_post
    # grab the sorter
		@sorter = SortingHelper::Sorter.new self, %w(created_at name title is_approved), params[:sort], (params[:order] ? params[:order] : 'DESC'), 'created_at', 'ASC'
		# grab the paginator
    @comment_pages = Paginator.new self, Comment.count_by_sql(['select count(*) from comments where post_id = ?', params[:id]]), 20, params[:page]
    # grab the comments (join on posts for titles)
		@comments = Comment.find(:all, :select => 'comments.*, posts.title', :joins => 'left outer join posts on comments.post_id = posts.id', :conditions => ['post_id = ?', params[:id]], :order => @sorter.to_sql, :limit => @comment_pages.current.to_sql)
		$admin_page_title = 'Listing comments'
		render :template => 'admin/comments/comment_list'
	end

	# load the comment we're editing
	def comment_edit
		@comment  = Comment.find(params[:id])
		@preview  = (@comment.body ? @comment.body : '')
		$admin_page_title = 'Editing comment'
		@onload   = "document.forms['comment_form'].elements['comment[body]'].focus()"
		@items    = (Blacklist.cache.length > 0 ? Blacklist.cache : Blacklist.find(:all, :select => 'item', :order => 'item asc'))
		render :template => 'admin/comments/comment_edit'
	end

  # update an existing comment
	def comment_update
	  # find our comment
		@comment = Comment.find(params[:id])
		if @comment.update_attributes(params[:comment])
		# comment was updated successfully
			flash[:notice] = 'Comment was updated.'
			if Preference.get_setting('RETURN_TO_COMMENT') == 'yes'
			# if they have a pref set as such, return them to the comment,
			# rather than the list
			  redirect_to Site.full_url + '/admin/comments/edit/' + @comment.id.to_s
			else
			  redirect_to Site.full_url + '/admin/comments'
		  end
		else
		# whoops!
		  @items   = Blacklist.find(:all, :select => 'item')
		  @preview = (@comment.body_raw ? @comment.body_raw: '')
		  # remember the update checking if it's there
		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'comment_edit', :template => 'admin/comments/comment_edit'
		end
	end

	# destroy an existing comment! destroy! destroy! destory!
	def comment_destroy
		Comment.find(params[:id]).destroy
		flash[:notice] = 'Comment was destroyed.'
		if session[:was_searching]
		# they came from somewhere, let's send them back there
			session[:was_searching] = nil
			q = session[:prev_search_string]
			session[:prev_search_string] = nil
			redirect_to Site.full_url + '/admin/comments/search?q=' + q
		else
		# not sure where they came from, just send them to normal place
			redirect_to Site.full_url + '/admin/comments'
		end
	end
  
  # create a filter-passed preview of the comment, checking for malformed XHTML
	def comment_preview
	  # add the body if we've got it
	  body = '' + (check_for_bad_xhtml(params[:comment][:body_raw], 'comment') if params[:comment][:body_raw])
	  # dump it out
	  render :text => body
  end
  
  # search for comments
  def comment_search
    session[:was_searching] = 1
    session[:prev_search_string] = params[:q]
    @comments = Comment.find_by_string(params[:q], 20)
    $admin_page_title = 'Search results'
    render :template => 'admin/comments/comment_search'
  end
	
	# toggles a comment's approval status based on params
	def comment_approval
	  comment = Comment.find(params[:id])
	  comment.update_attribute('is_approved', !comment.is_approved)
	  render :nothing => true
  end
  
  # turn comments system on and off
  def comments_toggle
    Preference.set_setting('commenting_on', (Preference.get_setting('commenting_on') == 'yes' ? 'no' : 'yes'))
    if session[:was_searching]
		# they were searching, send them back to results
			session[:was_searching] = nil
			q = session[:prev_search_string]
			session[:prev_search_string] = nil
			redirect_to Site.full_url + '/admin/posts/search?q=' + q
		elsif session[:came_from]
  	# they came from somewhere, let's send them back there
  			session[:came_from] = nil
  			redirect_to :back
  	else
  	# not sure where they came from, just send them to normal place
  		redirect_to Site.full_url + '/admin/posts'
  	end
  end
  
  # approve all comments that aren't approved
  def comments_approve_all
    comments = Comment.find_unapproved
    for c in comments
      c.update_attribute('is_approved', true)
    end
    flash[:notice] = 'All unapproved comments have been approved.'
    redirect_to Site.full_url + '/admin/comments'
  end
  
  # delete all comments that aren't approved
  def comments_delete_unapproved
    comments = Comment.find_unapproved
    for c in comments
      c.destroy
    end
    flash[:notice] = 'All unapproved comments have been deleted.'
    redirect_to Site.full_url + '/admin/comments'
  end
  
end