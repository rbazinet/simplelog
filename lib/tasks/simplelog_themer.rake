# $Id: simplelog_themer.rake 300 2007-02-01 23:01:00Z garrett $

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
# this will create a theme compatible with SimpleLog 1.1 from your currently
# customized 1.0 installation
#

namespace :simplelog do

require 'find'

desc "Creates a theme from your current customized views and supporting files for use in SimpleLog 1.1 (BACK UP YOUR SITE FIRST!)"
task :themer => :environment do
  puts "Moving your current views to theme directory called 'onepointoh'..."
  puts "Creating theme directories..."
  mkdir_p "onepointoh"
  mkdir_p "onepointoh/images"
  mkdir_p "onepointoh/javascripts"
  mkdir_p "onepointoh/layouts"
  mkdir_p "onepointoh/stylesheets"
  mkdir_p "onepointoh/views"
  mkdir_p "onepointoh/views/author"
  mkdir_p "onepointoh/views/post"
  # copy the view files
  puts "Copying view files..."
  # copy the layout
  File.copy "app/views/layouts/post.rhtml", "onepointoh/layouts/post.rhtml" rescue puts 'Post layout not found!'
  # copy the author views
  Find.find("app/views/author") do |ofile|
    if !File.directory?(ofile)
      nfile = ofile.gsub("app/views/author", "onepointoh/views/author")
      puts "Copying #{nfile}"
      File.copy ofile, nfile rescue puts 'Copy failed!'
    end
  end
  # copy the post views
  Find.find("app/views/post") do |ofile|
    if !File.directory?(ofile)
      nfile = ofile.gsub("app/views/post", "onepointoh/views/post")
      puts "Copying #{nfile}"
      File.copy ofile, nfile rescue puts 'Copy failed!'
    end
  end
  # grab the unknown request view
  Find.find("app/views/application") do |ofile|
    if !File.directory?(ofile)
      if ofile == "app/views/application/handle_unknown_request.rhtml"
        nfile = ofile.gsub("app/views/application", "onepointoh/views/post")
        puts "Copying #{nfile}"
        File.copy ofile, nfile rescue puts 'Copy failed!'
      end
    end
  end
  # create search view for posts
  File.open("onepointoh/views/post/search.rhtml", 'w') do |f|
    file_contents = '<%
  if @posts and @posts.length > 0
  # there were posts returned by this search
  	# begin an ordered list
  	output = \'<ol>\'
  	# loop through the result posts
  	for post in @posts
  		# add a list item with a link to the post and a short preview
  		output += \'<li>\'
  		output += "<a href=\"#{Post.permalink(post)}\" title=\"View &quot;#{post.title}&quot;\">" + post.title + \'</a>\'
  		output += \':&nbsp;&nbsp;\' + truncate_words(Post.strip_html(post.body), 20)
  		output += \'</li>\' 
  	end
  	# we\'re done, let\'s dump out our list (with the closing tag)
      %><%= output + \'</ol>\' %><%
  else
  # no results, return message
      %>There were no results, sorry. Try being more specific or a different query.<%
  end
%>'
    f.write(file_contents)
  end
  # copy images
  puts "Copying images..."
  Find.find("public/images") do |ofile|
    Find.prune if ofile == 'public/images/admin'
    if !File.directory?(ofile)
      nfile = ofile.gsub("public/images", "onepointoh/images")
      puts "Copying #{nfile}"
      File.copy ofile, nfile rescue puts 'Copy failed!'
    end
  end
  # copy javascripts
  puts "Copying javascripts..."
  Find.find("public/javascripts") do |ofile|
    if !File.directory?(ofile) and ofile != 'public/javascripts/admin.js'
      nfile = ofile.gsub("public/javascripts", "onepointoh/javascripts")
      puts "Copying #{nfile}"
      File.copy ofile, nfile rescue puts 'Copy failed!'
    end
  end
  # copy stylesheets
  puts "Copying stylesheets..."
  Find.find("public/stylesheets") do |ofile|
    if !File.directory?(ofile) and ofile != 'public/stylesheets/admin.css'
      nfile = ofile.gsub("public/stylesheets", "onepointoh/stylesheets")
      puts "Copying #{nfile}"
      File.copy ofile, nfile rescue puts 'Copy failed!'
    end
  end
  # create the about and author files
  puts "Creating author and about files..."
  File.open("onepointoh/author.markdown", 'w') do |f|
    contents = ''
    f.pos = 0
    f.print contents
    f.truncate(f.pos)
  end
  File.open("onepointoh/about.markdown", 'w') do |f|
    contents = 'A converted theme from SimpleLog 1.0.'
    f.pos = 0
    f.print contents
    f.truncate(f.pos)
  end
  # all done!
  puts "Done copying."
  
  puts "Upgrading theme to new preference reference style (this may take a few moments)..."
  # now let's replace ENV references, and incorrect file paths for styles, jscripts, etc
  File.open("onepointoh/layouts/post.rhtml", 'r+') do |f|
    input = ''
    f.each do |line|
      input << line
    end
    input = input.gsub("<% if ENV['MINT_DIR'] != '' -%><script src=\"/<%= ENV['MINT_DIR'] %>/?js\" type=\"text/javascript\"></script><% end %>", "<% if get_pref('MINT_DIR') != '' -%><script src=\"<%= get_pref('MINT_DIR') + (get_pref('MINT_DIR')[-1..get_pref('MINT_DIR').length] == '/' ? '' : '/')%>?js\" type=\"text/javascript\"></script><% end %>")
    input = input.gsub(/ENV\[\'([A-Za-z0-9_]+)?\'\]/i, 'get_pref(\'\\1\')')
    input = input.gsub("get_pref('VERSION')", 'SL_CONFIG[:VERSION]')
    input = input.gsub('stylesheet_link_tag', 'theme_stylesheet_link_tag')
    input = input.gsub('javascript_include_tag', 'theme_javascript_include_tag')
    f.pos = 0
    f.print input
    f.truncate(f.pos)
  end
  # handle the author views
  Find.find("app/views/author") do |ofile|
    if !File.directory?(ofile)
      nfile = ofile.gsub("app/views/author", "onepointoh/views/author")
      File.open(nfile, 'r+') do |f|
        input = ''
        f.each do |line|
          input << line
        end
        input = input.gsub(/ENV\[\'([A-Za-z0-9_]+)?\'\]/i, 'get_pref(\'\\1\')')
        f.pos = 0
        f.print input
        f.truncate(f.pos)
      end
    end
  end
  # handle the post views
  Find.find("app/views/post") do |ofile|
    if !File.directory?(ofile)
      nfile = ofile.gsub("app/views/post", "onepointoh/views/post")
      File.open(nfile, 'r+') do |f|
        input = ''
        f.each do |line|
          input << line
        end
        input = input.gsub(/ENV\[\'([A-Za-z0-9_]+)?\'\]/i, 'get_pref(\'\\1\')')
        if nfile == 'onepointoh/views/post/_about_site.rhtml'
          input = input.gsub(":url => '/past/do_search'", ":url => '/search'")
        end
        f.pos = 0
        f.print input
        f.truncate(f.pos)
      end
    end
  end
  # handle relative image references in stylesheets and javascript files
  Find.find("public/javascripts") do |ofile|
    if !File.directory?(ofile) and ofile != 'public/javascripts/admin.js'
      nfile = ofile.gsub("public/javascripts", "onepointoh/javascripts")
      File.open(nfile, 'r+') do |f|
        input = ''
        f.each do |line|
          input << line
        end
        input = input.gsub(/([^\.\.])\/images/i, '\\1../images')
        f.pos = 0
        f.print input
        f.truncate(f.pos)
      end
    end
  end  
  Find.find("public/stylesheets") do |ofile|
    if !File.directory?(ofile) and ofile != 'public/stylesheets/admin.css'
      nfile = ofile.gsub("public/stylesheets", "onepointoh/stylesheets")
      File.open(nfile, 'r+') do |f|
        input = ''
        f.each do |line|
          input << line
        end
        input = input.gsub(/([^\.\.])\/images/i, '\\1../images')
        f.pos = 0
        f.print input
        f.truncate(f.pos)
      end
    end
  end
    
  puts "Done upgrading theme."
  puts "Theme created successfully! You will now find the 'onepointoh' directory in your rails root!"
end

end