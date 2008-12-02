namespace :themes do
  
desc "Creates the cached (public) theme folders"
task :create_cache do
  for theme in Dir.glob("#{RAILS_ROOT}/themes/*")
    theme_name = theme.split( File::Separator )[-1]
    puts "Creating #{RAILS_ROOT}/public/themes/#{theme_name}"
    
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/themes/#{theme_name}"
        
    FileUtils.cp_r "#{theme}/images", "#{RAILS_ROOT}/public/themes/#{theme_name}/images", :verbose => true
    FileUtils.cp_r "#{theme}/stylesheets", "#{RAILS_ROOT}/public/themes/#{theme_name}/stylesheets", :verbose => true
    FileUtils.cp_r "#{theme}/javascripts", "#{RAILS_ROOT}/public/themes/#{theme_name}/javascripts", :verbose => true
    FileUtils.cp_r "#{theme}/preview.png", "#{RAILS_ROOT}/public/themes/#{theme_name}/preview.png", :verbose => true
  end
end

desc "Removes the cached (public) theme folders"
task :remove_cache do
  puts "Removing #{RAILS_ROOT}/public/themes"
  FileUtils.rm_r "#{RAILS_ROOT}/public/themes", :force => true
end

desc "Updates the cached (public) theme folders"
task :update_cache => ['themes:remove_cache', 'themes:create_cache']

end