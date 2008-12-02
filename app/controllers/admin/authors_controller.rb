# $Id: authors_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::AuthorsController < Admin::BaseController
  
  #
  # authors, oh authors, you write your sweet prose
  #
  
  # get a list of authors, paginated, with sorting
	def author_list
	  # grab the sorter
		@sorter = SortingHelper::Sorter.new self, %w(created_at name email total_posts is_active), params[:sort], params[:order], 'name', 'ASC'
		# grab the paginator
    @author_pages = Paginator.new self, Author.count, 20, params[:page]
    # grab the authors, join to the posts table so that we can sort on the post count as well
		@authors = Author.find(:all, :select => 'authors.id, authors.created_at, authors.email, authors.name, authors.is_active, count(posts.id) as total_posts', :joins => 'left outer join posts on authors.id = posts.author_id', :group => 'authors.id, authors.created_at, authors.email, authors.name, authors.is_active', :order => @sorter.to_sql, :limit => @author_pages.items_per_page, :offset => @author_pages.current.offset)
		$admin_page_title = 'Listing authors'
		render :template => 'admin/authors/author_list'
	end
	
	# show a author's info and the posts they've written
	def author_show
	  @author = Author.find(params[:id])
	  $admin_page_title = 'Showing posts by "' + @author.name + '"'
	  render :template => 'admin/authors/author_show'
  end

  # create a new author
	def author_new
		@author = Author.new
		$admin_page_title = 'New author'
		@onload = "document.forms['author_form'].elements['author[name]'].focus()"
		render :template => 'admin/authors/author_new'
	end
	
	# save a new author
	def author_create
	  # let's create our new author
		@author = Author.new(params[:author])
		if @author.save
		# author was saved successfully
			flash[:notice] = '<b>Success:</b> Author was created.'
			redirect_to Site.full_url + '/admin/authors'
		else
		# whoops!
		  # remember the update checking if it's there
	    @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'author_new', :template => 'admin/authors/author_new'
		end
	end

	# load the author we're editing
	def author_edit
		@author = Author.find(params[:id])
		@posts = @author.posts
		$admin_page_title = 'Editing author'
		@onload = "document.forms['author_form'].elements['author[name]'].focus()"
		render :template => 'admin/authors/author_edit'
	end

  # update an existing author
	def author_update
	  # find our author
		@author = Author.find(params[:id])
		if (Author.find(:all, :conditions => ['is_active = true and id != ?', params[:id]]).length < 1) and params[:author][:is_active] == '0'
		# trying to set this author to inactive, but it would lock them out of the admin section--don't do it
		  flash[:notice] = '<span class="red"><b>Failed:</b> Setting that author to inactive would lock you out!</span>'
		  redirect_to Site.full_url + '/admin/authors'
	  else
		  if @author.update_attributes(params[:author])
  		# author was updated successfully
  			flash[:notice] = '<b>Success:</b> Author was updated.'
  			redirect_to Site.full_url + '/admin/authors'
  		else
  		# whoops!
  		  @posts = @author.posts
  		  # remember the update checking if it's there
  		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
  			render :action => 'author_edit', :template => 'admin/authors/author_edit'
  		end
		end
	end

  # destroy an existing author! destroy! destroy! destory!
  # check to make sure they're not going to lock themselves out first...
	def author_destroy
	  if (Author.count < 2) or (Author.find(:all, :conditions => ['is_active = true and id != ?', params[:id]]).length < 1)
	    flash[:notice] = '<b>Failed:</b> Destroying that author would lock you out!'
	    if session[:came_from]
  		# they came from somewhere, let's send them back there
  			temp = session[:came_from]
  			session[:came_from] = nil
  			redirect_to :back
  		else
  		# not sure where they came from, just send them to normal place
  			redirect_to Site.full_url + '/admin/authors'
  		end
    else
		  Author.find(params[:id]).destroy
		  flash[:notice] = '<b>Success:</b> Author was destroyed.'
		  if session[:came_from]
  			temp = session[:came_from]
  			session[:came_from] = nil
  			redirect_to :back
  		else
  			redirect_to Site.full_url + '/admin/authors'
  		end
	  end
	end
  
end