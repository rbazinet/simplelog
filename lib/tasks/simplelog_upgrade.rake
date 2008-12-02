# $Id: simplelog_upgrade.rake 329 2007-02-09 19:39:12Z garrett $

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
# this rake task should be run every time you upgrade simplelog
# it updates the database (migrations) and other various things that are necessary
#
# ALWAYS RUN THIS WHEN UPGRADING!
#

namespace :simplelog do
  
require 'find'
require 'environment.rb'

desc "Upgrade SimpleLog (BACK UP YOUR SITE FIRST!)"
task :upgrade => :environment do
  
  # run the db migrations
  puts "\nUpdating database if necessary..."
  Rake::Task['db:migrate'].invoke
  puts "Done!\n"
  
  # making theme backups
  puts "\nMaking backups of themes before making changes..."
  bk_fld_name = 'theme_backup/' + Time.new.strftime('%Y%m%d%H%M%S')
  if File.exist?('theme_backup')
    if !File.exist?(bk_fld_name)
      mkdir_p bk_fld_name
      Find.find('themes') do |path|
        if path != 'themes' and path != 'themes/.svn' and path != 'themes/.DS_Store' and path != 'themes/THEME_CHANGES_IN_2.X'
          File.cp_r path, bk_fld_name
        end
        Find.prune if path != 'themes'
      end
    end
  else
    puts "Couldn't back up themes! Be sure to have a writable 'theme_backup' dir (see README)!"
  end
  puts "Done!\n"
  
  # check for missing theme files
  puts "\nChecking your themes for required files..."
  
  Find.find("themes") do |path|    
    if File.directory?(path)
      next if path.index('.svn') or path == 'themes'

      puts "---------------------------------------"
      puts "Verifying '#{path.gsub('themes/', '')}' theme..."
      
      if File.exist?(path + '/views/archives')
        
        ### POST 2.0!
        
        puts "'#{path.gsub('themes/', '')}' theme is post-2.0, skipping theme conversion..."
        puts "Confirming list of required files..."
        if !File.exist?(path + '/views/search/full_results.rhtml')
          if File.exist?(path + '/views/search/results.rhtml')
            File.copy(path + '/views/search/results.rhtml', path + '/views/search/full_results.rhtml')
          end
        end
        puts "Done!"
      else
        
      ### PRE 2.0!
      
      puts "Checking for pages directory..."
      if !File.exist?(path + '/views/page')
      # pages dir doesn't exist
        puts "Pages directory doesn't exist, creating..."
        mkdir_p path + '/views/page'
        puts "Done!"
        # create the file now, too
        puts "Creating view file..."
        File.open(path + '/views/page/show.rhtml', 'w') do |f|
          file_contents = '<div class="item">' + "\n\t" + '<%= @page.body %>' + "\n" + '</div>'
          f.write(file_contents)
        end
        puts "Done!"
      else
        puts "Exists."
      end
      
      puts "Checking for all required files..."
      if !File.exist?(path + '/views/post/archives_list.rhtml')
        puts "Creating #{path}/views/post/archives_list.rhtml"
        File.open(path + '/views/post/archives_list.rhtml', 'w') do |f|
          file_contents = '<p>Here\'s a list of all posts available at this site, ordered chronologically newest to oldest. Monthly archives are also available.</p>
<dl>
    <%
    cy = 0
    cm = 0
    closed_y = true
    closed_m = true
    keep_month = \'\'
    keep_year = \'\'
    output = \'\'
    for p in @posts

        if keep_year != p.created_at.year
            if cy != 0
                output << "</dt>"
                closed_y = true
                cy = 0
            end
            output << "<dt><h3>#{p.created_at.year}</h3>"
            closed_y = false
        end
        if keep_month != p.created_at.month
            if cm != 0
                output << "</dt>"
                closed_m = true
                cm = 0
            end
            output << "<dt><h4>#{link_to(p.created_at.strftime(\'%B\'), \'/\' + get_pref(\'ARCHIVE_TOKEN\') + \'/\' + p.created_at.strftime(\'%Y/%m\'))}</h4>"
            closed_m = false
        end
        output << "<dd>#{link_to(p.title, Post.permalink(p))}</dd>"

        keep_month = p.created_at.month
        keep_year = p.created_at.year
        cy += 1
        cm += 1
    end
    %>
    <%= output + (!closed_y ? \'</dt>\' : \'\') + (!closed_m ? \'</dt>\' : \'\') %>
</dl>'
          f.write(file_contents)
        end
        puts "Done!"
      end
      if !File.exist?(path + '/views/post/by_day.rhtml')
        puts "Creating #{path}/views/post/by_day.rhtml"
        File.open(path + '/views/post/by_day.rhtml', 'w') do |f|
          file_contents = '<%
# let\'s loop!
for post in @posts
	# let\'s show the post
	%><%= render :partial => \'post_item\', :locals => {:post => post, :detail => false, :time_only => false} %><%
end
%>'
          f.write(file_contents)
        end
        puts "Done!"
      end
      if !File.exist?(path + '/views/post/by_month.rhtml')
        puts "Creating #{path}/views/post/by_month.rhtml"
        File.open(path + '/views/post/by_month.rhtml', 'w') do |f|
          file_contents = '<%
# let\'s loop!
for post in @posts
	# let\'s show the post
	%><%= render :partial => \'post_item\', :locals => {:post => post, :detail => false, :time_only => false} %><%
end
%>'
          f.write(file_contents)
        end
        puts "Done!"
      end
      if !File.exist?(path + '/views/post/by_year.rhtml')
        puts "Creating #{path}/views/post/by_year.rhtml"
        File.open(path + '/views/post/by_year.rhtml', 'w') do |f|
          file_contents = '<%
# let\'s loop!
for post in @posts
	# let\'s show the post
	%><%= render :partial => \'post_item\', :locals => {:post => post, :detail => false, :time_only => false} %><%
end
%>'
          f.write(file_contents)
        end
        puts "Done!"
      end
      if !File.exist?(path + '/views/post/feed_comments_rss.rxml')
        puts "Creating #{path}/views/post/feed_comments_rss.rxml"
        File.open(path + '/views/post/feed_comments_rss.rxml', 'w') do |f|
          file_contents = 'xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
	xml.channel do

    xml.title(get_pref(\'SITE_NAME\') + \': Comments\')
  	xml.link(\'http://\' + get_pref(\'DOMAIN\'))
  	xml.language(get_pref(\'LANGUAGE\'))
  	xml.webMaster(get_pref(\'AUTHOR_EMAIL\') + \' (\' + get_pref(\'SITE_PRIMARY_AUTHOR\') + \')\')
  	xml.copyright(\'Copyright \' + get_pref(\'COPYRIGHT_YEAR\') + (Time.sl_local.year.to_s != get_pref(\'COPYRIGHT_YEAR\') ? \'-\' + Time.sl_local.year.to_s : \'\'))
  	xml.ttl(\'60\')
  	xml.pubDate(CGI.rfc1123_date(Time.sl_localize(@comments.first.modified_at))) if @comments.any?
  	xml.description(get_pref(\'SLOGAN\'))

  	for comment in @comments do
  	  use_post = comment.post
  		xml.item do
  			xml.title(Post.to_synd_title(comment.body))
  			xml.link(\'http://\' + get_pref(\'DOMAIN\') + Post.permalink(use_post) + \'#c\' + comment.id.to_s)
  			xml.pubDate(CGI.rfc1123_date(Time.sl_localize(comment.created_at)))
  			xml.link(\'http://\' + get_pref(\'DOMAIN\') + Post.permalink(use_post) + \'#c\' + comment.id.to_s)
  			xml.author(comment.name)
  			xml.description(comment.body + \'<p>Posted to: \' + link_to((get_pref(\'SIMPLE_TITLES\') == \'yes\' ? use_post.synd_title : use_post.title), Post.permalink(use_post)))
  		end
  	end

	end
end'
          f.write(file_contents)
        end
        puts "Done!"
      end
      if !File.exist?(path + '/views/post/tags_list.rhtml')
        puts "Creating #{path}/views/post/tags_list.rhtml"
        File.open(path + '/views/post/tags_list.rhtml', 'w') do |f|
          file_contents = '<p>Here\'s a list of all tags available at this site, ordered alphabetically.</p>

<%= build_tag_list(@tags) %>'
          f.write(file_contents)
        end
        puts "Done!"
      end
      
      puts "Removing deprecated views..."
      if File.exist?(path + '/views/author')
        remove_dir path + '/views/author'
      end
      if File.exist?(path + '/layouts/page.rhtml')
        File.delete(path + '/layouts/page.rhtml')
      end
      puts "Done!"
      
      puts "Updating references in views to external built-in files..."
      # the post layout file
      if File.exist?(path + '/layouts/post.rhtml')
        File.open(path + '/layouts/post.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= theme_javascript_include_tag 'prototype' %>", "<%= javascript_include_tag Site.full_url + '/javascripts/prototype.js' %>")
          input = input.gsub("<%= javascript_include_tag 'prototype' %>", "<%= javascript_include_tag Site.full_url + '/javascripts/prototype.js' %>")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # the javascript file
      if File.exist?(path + '/javascripts/lightbox.js')
        File.open(path + '/javascripts/lightbox.js', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("loadingImage = '../images/loading.gif';", "loadingImage = '../../../images/loading.gif';")
          input = input.gsub("loadingImage = '/images/loading.gif';", "loadingImage = '../../../images/loading.gif';")
          input = input.gsub("loadingImage = '../../../images/loading.gif';", "loadingImage = '/images/loading.gif';")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # the stylesheet file
      if File.exist?(path + '/stylesheets/lightbox.css')
        File.open(path + '/stylesheets/lightbox.css', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("background-image: url(../images/overlay.png);", "background-image: url(../../../images/overlay.png);")
          input = input.gsub("background-image: url(/images/overlay.png);", "background-image: url(../../../images/overlay.png);")
          input = input.gsub('AlphaImageLoader(src="../images/overlay.png"', 'AlphaImageLoader(src="../../../images/overlay.png"')
          input = input.gsub('AlphaImageLoader(src="/images/overlay.png"', 'AlphaImageLoader(src="../../../images/overlay.png"')
          input = input.gsub('AlphaImageLoader(src="../../../images/overlay.png"', 'AlphaImageLoader(src="/images/overlay.png"')
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # fix bad tags method ref in tags list view
      if File.exist?(path + '/views/post/tags_list.rhtml')
        File.open(path + '/views/post/tags_list.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= build_tag_list(@tags) %>", "<%= build_tag_archive_list(@tags) %>")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      
      puts "Rearranging theme files for 2.0+ structure..."
      
      # rename layout
      if File.exist?(path + '/layouts/post.rhtml')
        File.rename path + '/layouts/post.rhtml', path + '/layouts/site.rhtml' rescue puts 'Rename failed!'
        puts "Renaming layout file... done!"
      end
      puts "Adding new directories..."
      if !File.exist?(path + '/views/archives')
        mkdir_p path + '/views/archives'
      end
      if !File.exist?(path + '/views/errors')
        mkdir_p path + '/views/errors'
      end
      if !File.exist?(path + '/views/feeds')
        mkdir_p path + '/views/feeds'
      end
      if !File.exist?(path + '/views/includes')
        mkdir_p path + '/views/includes'
      end
      if !File.exist?(path + '/views/pages')
        mkdir_p path + '/views/pages'
      end
      if !File.exist?(path + '/views/posts')
        mkdir_p path + '/views/posts'
      end
      if !File.exist?(path + '/views/search')
        mkdir_p path + '/views/search'
      end
      if !File.exist?(path + '/views/errors')
        mkdir_p path + '/views/errors'
      end  
      puts "Done!"
      
      puts "Moving/renaming files..."
      if File.exist?(path + '/views/post/archives_list.rhtml')
        File.move(path + '/views/post/archives_list.rhtml', path + '/views/archives/list.rhtml')
      end
      if File.exist?(path + '/views/post/by_author.rhtml')
        File.move(path + '/views/post/by_author.rhtml', path + '/views/archives/by_author.rhtml')
      end
      if File.exist?(path + '/views/post/by_day.rhtml')
        File.move(path + '/views/post/by_day.rhtml', path + '/views/archives/daily.rhtml')
      end
      if File.exist?(path + '/views/post/by_month.rhtml')
        File.move(path + '/views/post/by_month.rhtml', path + '/views/archives/monthly.rhtml')
      end
      if File.exist?(path + '/views/post/by_year.rhtml')
        File.move(path + '/views/post/by_year.rhtml', path + '/views/archives/yearly.rhtml')
      end
      if File.exist?(path + '/views/post/feed_all_rss.rxml')
        File.move(path + '/views/post/feed_all_rss.rxml', path + '/views/feeds/posts.rxml')
      end
      if File.exist?(path + '/views/post/feed_comments_rss.rxml')
        File.move(path + '/views/post/feed_comments_rss.rxml', path + '/views/feeds/comments.rxml')
      end
      if File.exist?(path + '/views/post/handle_unknown_request.rhtml')
        File.move(path + '/views/post/handle_unknown_request.rhtml', path + '/views/errors/unknown_request.rhtml')
      end
      if File.exist?(path + '/views/post/list.rhtml')
        File.move(path + '/views/post/list.rhtml', path + '/views/index.rhtml')
      end
      if File.exist?(path + '/views/post/search.rhtml')
        File.move(path + '/views/post/search.rhtml', path + '/views/search/results.rhtml')
      end
      if File.exist?(path + '/views/search/results.rhtml')
        File.copy(path + '/views/search/results.rhtml', path + '/views/search/full_results.rhtml')
      end
      if File.exist?(path + '/views/post/show.rhtml')
        File.move(path + '/views/post/show.rhtml', path + '/views/posts/show.rhtml')
      end
      if File.exist?(path + '/views/post/tagged.rhtml')
        File.move(path + '/views/post/tagged.rhtml', path + '/views/archives/by_tag.rhtml')
      end
      if File.exist?(path + '/views/post/tags_list.rhtml')
        File.move(path + '/views/post/tags_list.rhtml', path + '/views/archives/list_tags.rhtml')
      end
      if File.exist?(path + '/views/post/_post_item.rhtml')
        File.move(path + '/views/post/_post_item.rhtml', path + '/views/posts/_item.rhtml')
      end
      if File.exist?(path + '/views/posts/_item.rhtml')
        File.copy(path + '/views/posts/_item.rhtml', path + '/views/posts/_item_detailed.rhtml')
      end
      if File.exist?(path + '/views/post/_bottom_nav.rhtml')
        File.move(path + '/views/post/_bottom_nav.rhtml', path + '/views/includes/_bottom_nav.rhtml')
      end
      if File.exist?(path + '/views/post/_sidebar.rhtml')
        File.move(path + '/views/post/_sidebar.rhtml', path + '/views/includes/_sidebar.rhtml')
      end
      if File.exist?(path + '/views/page/show.rhtml')
        File.move(path + '/views/page/show.rhtml', path + '/views/pages/show.rhtml')
      end
      if !File.exist?(path + '/views/includes/_browser_check.rhtml')
        File.open(path + '/views/includes/_browser_check.rhtml', 'w') do |f|
          file_contents = '<%
# you can customize these warnings if you wish or get rid of them
# altogether by changing your preferences or emptying this file
if get_pref(\'WARN_BAD_BROWSERS\') == \'yes\'
	# run the check_browser method
	check_browser
	if @bad_browser
	# this is IE (or possibly Opera), let\'s give them a warning
-%>
	<div id="warn_bad_browsers">
    	<% if @is_opera -%>
    	<% # this is an opera user -- customize the message for them %>
    	<b>Hello, Opera user.</b> You should use <a href="http://getfirefox.com" title="Firefox">something better</a>.
    	<% else -%>
    	<% # this is an IE user -- customize the message for them %>
    	<b>Hello, IE user.</b> You should use <a href="http://getfirefox.com" title="Firefox">something better</a>.
    	<% end -%>
	</div>
<%
	end
end
# done with the browser check
-%>'
          f.write(file_contents)
        end
      end
      puts "Done!"
      
      readme_note = "The files included in this directory are any theme files from your old theme that weren't part of the default file structure. Because they weren't part of the default, SimpleLog didn't know what to do with them so it moved them here.\n\nYou'll need to move these files back into your theme and change any render commands that called them. Simply move these files back into your theme and then update any <%= render :partial %> code.\n\nIf the files in this directory are partials (i.e., they start with a \"_\"), the best place is probably the views/includes directory."
      puts "Renaming or removing old directories..."
      ignoring_these = ['.', '..', '.svn', '.DS_Store', 'thumbs.db']
      if File.exist?(path + '/views/post')
        remaining_files = false
        items_in_dir = Dir.entries(path + '/views/post')
        for ix in items_in_dir
          if !ignoring_these.index(ix)
            remaining_files = true
          end
        end
        
        if remaining_files
          File.move(path + '/views/post', path + '/views/old_post_files')
          if !File.exist?(path + '/views/old_post_files/README')
            File.open(path + '/views/old_post_files/README', 'w') do |f|
              file_contents = readme_note
              f.write(file_contents)
            end
          end
        else
          remove_dir path + '/views/post'
        end
      end
      if File.exist?(path + '/views/page')
        remaining_files = false
        items_in_dir = Dir.entries(path + '/views/page')
        for ix in items_in_dir
          if !ignoring_these.index(ix)
            remaining_files = true
          end
        end
        
        if remaining_files
          File.move(path + '/views/page', path + '/views/old_page_files')
          if !File.exist?(path + '/views/old_page_files/README')
            File.open(path + '/views/old_page_files/README', 'w') do |f|
              file_contents = readme_note
              f.write(file_contents)
            end
          end
        else
          remove_dir path + '/views/page'
        end
      end
      puts "Done!"
      
      # now we have to fix references... ugh!
      puts "Attemping to fix references..."
      # the layout
      if File.exist?(path + '/layouts/site.rhtml')
        File.open(path + '/layouts/site.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post/sidebar' %>", "<%= render :partial => 'includes/sidebar' %>")
          input = input.gsub("<%= render :partial => 'post/bottom_nav' %>", "<%= render :partial => 'includes/footer' %>")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # search URL
      if File.exist?(path + '/views/includes/_sidebar.rhtml')
        File.open(path + '/views/includes/_sidebar.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub(":url => '/search') %>", ":url => \"\#{Site.full_url}/search\") -%>")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # by author
      if File.exist?(path + '/views/archives/by_author.rhtml')
        File.open(path + '/views/archives/by_author.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # by day
      if File.exist?(path + '/views/archives/daily.rhtml')
        File.open(path + '/views/archives/daily.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # by month
      if File.exist?(path + '/views/archives/monthly.rhtml')
        File.open(path + '/views/archives/monthly.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # by year
      if File.exist?(path + '/views/archives/yearly.rhtml')
        File.open(path + '/views/archives/yearly.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # by tag
      if File.exist?(path + '/views/archives/by_tag.rhtml')
        File.open(path + '/views/archives/by_tag.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # index
      if File.exist?(path + '/views/index.rhtml')
        File.open(path + '/views/index.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # show
      if File.exist?(path + '/views/posts/show.rhtml')
        File.open(path + '/views/posts/show.rhtml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("<%= render :partial => 'post_item'", "<%= render :partial => 'posts/item_detailed'")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end      
      # posts feed
      if File.exist?(path + '/views/feeds/posts.rxml')
        File.open(path + '/views/feeds/posts.rxml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("xml.link('http://' + get_pref('DOMAIN'))", "xml.link(Site.full_url)")
          input = input.gsub("'http://' + get_pref('DOMAIN') + Post.permalink(post)", "Post.permalink(post)")
          input = input.gsub("'http://' + get_pref('DOMAIN') + '/' + get_pref('ARCHIVE_TOKEN') + '/tags/' + tag", "Site.full_url + '/' + get_pref('ARCHIVE_TOKEN') + '/tags/' + tag")
          input = input.gsub("CGI.rfc1123_date(@posts.first.modified_at))", "CGI.rfc1123_date(Time.sl_localize(@posts.first.modified_at)))")
          input = input.gsub("CGI.rfc1123_date(post.created_at))", "CGI.rfc1123_date(Time.sl_localize(post.created_at)))")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      # comments feed
      if File.exist?(path + '/views/feeds/comments.rxml')
        File.open(path + '/views/feeds/comments.rxml', 'r+') do |f|
          input = ''
          f.each do |line|
            input << line
          end
          input = input.gsub("xml.link('http://' + get_pref('DOMAIN'))", "xml.link(Site.full_url)")
          input = input.gsub("'http://' + get_pref('DOMAIN') + Post.permalink(use_post)", "Post.permalink(use_post)")
          input = input.gsub("'http://' + get_pref('DOMAIN') + '/' + get_pref('ARCHIVE_TOKEN') + '/tags/' + tag", "Site.full_url + '/' + get_pref('ARCHIVE_TOKEN') + '/tags/' + tag")
          input = input.gsub("CGI.rfc1123_date(@comments.first.modified_at))", "CGI.rfc1123_date(Time.sl_localize(@comments.first.modified_at)))")
          input = input.gsub("CGI.rfc1123_date(comment.created_at))", "CGI.rfc1123_date(Time.sl_localize(comment.created_at)))")
          f.pos = 0
          f.print input
          f.truncate(f.pos)
        end
      end
      puts "Done!\n"
      puts "You should double-check the '#{path.gsub('themes/', '')}' theme since changes were made."
      
      end
  
      # don't go deeper than this one level
      Find.prune if path != 'themes'
    end
  end
  puts "\nFinished checking themes!\n"
  
  puts "\nChecking for required environmental settings..."
  # the server.rb file
  if File.exist?('config/server.rb')
    File.open('config/server.rb', 'r+') do |f|
      input = ''
      f.each do |line|
        input << line
      end
      if !input.index('ActionMailer')
        output = ''
        content_split = input.split("##################################################################\n# Don't change anything below this line! Seriously!")
        output  = content_split[0].strip + "\n\n"
        output += "# Set your mail configuration for comment notification (optional)"
output += "
  ActionMailer::Base.server_settings = {
    :address        => '',
    :port           => 25, 
    :domain         => '',
    :user_name      => '',
    :password       => '',
    :authentication => :login
  }"
        input   = output
        f.pos   = 0
        f.print input
        f.truncate(f.pos)
        puts "Adding mail settings to server.rb... Done!"
      else
        puts "All settings exist!"
      end
    end
  end 
  puts "Done checking environment!\n\n"
  
  puts "SimpleLog has been updated to version #{SL_CONFIG[:VERSION]}.\n\n"
end

end