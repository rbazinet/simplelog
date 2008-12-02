# $Id: pages_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class Admin::PagesController < Admin::BaseController
  
  #
  # "static" pages are useful sometimes
  #
  
  # get a list of pages, paginated, with sorting
	def page_list
	  # grab the sorter
	  @sorter = SortingHelper::Sorter.new self, %w(created_at title permalink is_active), params[:sort], (params[:order] ? params[:order] : 'DESC'), 'created_at', 'ASC'
		# grab the paginator
    @page_pages = Paginator.new self, Page.count, 20, params[:page]
    # grab the pages
		@pages = Page.find(:all, :order => @sorter.to_sql, :limit => @page_pages.items_per_page, :offset => @page_pages.current.offset)
		$admin_page_title = 'Listing pages'
		render :template => 'admin/pages/page_list'
	end

  # create a new page
	def page_new
		@page     = Page.new
		$admin_page_title = 'New page'
		@onload   = "document.forms['page_form'].elements['page[permalink]'].focus()"
		render :template => 'admin/pages/page_new'
	end

  # save a new page
	def page_create
	  # let's create our new post
		@page = Page.new(params[:page])
		if @page.save
		# page was saved successfully
			flash[:notice] = 'Page was created.'
			if Preference.get_setting('RETURN_TO_PAGE') == 'yes'
			# if they have a pref set as such, return them to the page,
			# rather than the list
			  redirect_to Site.full_url + '/admin/pages/edit/' + @page.id.to_s
			else
			  redirect_to Site.full_url + '/admin/pages'
		  end
		else
		# whoops!
		  @preview  = (@page.body_raw ? @page.body_raw: '')
		  # remember the update checking if it's there
		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'page_new', :template => 'admin/pages/page_new'
		end
	end

	# load the page we're editing
	def page_edit
		@page     = Page.find(params[:id])
		@plink    = Post.permalink(@page[0])
		@preview  = (@page.body ? @page.body : '')
		$admin_page_title = 'Editing page'
		@onload   = "document.forms['page_form'].elements['page[permalink]'].focus()"
		render :template => 'admin/pages/page_edit'
	end

  # update an existing page
	def page_update
	  # find our post
		@page = Page.find(params[:id])
		if @page.update_attributes(params[:page])
		# page was updated successfully
			flash[:notice] = 'Page was updated.'
			if Preference.get_setting('RETURN_TO_PAGE') == 'yes'
			# if they have a pref set as such, return them to the page,
			# rather than the list
			  redirect_to Site.full_url + '/admin/pages/edit/' + @page.id.to_s
			else
			  redirect_to Site.full_url + '/admin/pages'
		  end
		else
		# whoops!
		  @preview  = (@page.body_raw ? @page.body_raw: '')
		  # remember the update checking if it's there
		  @update_checker = session[:update_check_stored] if session[:update_check_stored] != nil
			render :action => 'page_edit', :template => 'admin/pages/page_edit'
		end
	end

	# destroy an existing page! destroy! destroy! destory!
	def page_destroy
		Page.find(params[:id]).destroy
		flash[:notice] = 'Page was destroyed.'	
		if session[:was_searching]
		# they came from somewhere, let's send them back there
			session[:was_searching] = nil
			q = session[:prev_search_string]
			session[:prev_search_string] = nil
			redirect_to Site.full_url + '/admin/pages/search?q=' + q
		else
		# not sure where they came from, just send them to normal place
			redirect_to Site.full_url + '/admin/pages'
		end
	end
	
	# search for pages
  def page_search
    session[:was_searching] = 1
    session[:prev_search_string] = params[:q]
    @pages = Page.find_by_string(params[:q], 20, false)
    $admin_page_title = 'Search results'
    render :template => 'admin/pages/page_search'
  end
	
	# create a filter-passed preview of the page, checking for malformed XHTML
	def page_preview
	  # add the body if we've got it
	  body = '' + (check_for_bad_xhtml(params[:page][:body_raw], 'page', params[:page][:text_filter]) if params[:page][:body_raw])
	  # dump it out
	  render :text => body
  end
  
  # update the permalink and preview it
  def page_permalink
    render :text => Post.to_permalink(params[:value])
  end
  
end