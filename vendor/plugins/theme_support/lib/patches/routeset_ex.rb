# Extends <tt>ActionController::Routing::RouteSet</tt> to automatically add the theme routes
class ActionController::Routing::RouteSet

  alias_method :__draw, :draw

  # Overrides the default <tt>RouteSet#draw</tt> to automatically
  # include the routes needed by the <tt>ThemeController</tt>
  def draw
    old_routes = @routes
    @routes = []
    
    begin 
      create_theme_routes
      yield self
    rescue
      @routes = old_routes
      raise
    end
    
    write_generation
    write_recognition
  end

  # Creates the required routes for the <tt>ThemeController</tt>...
  def create_theme_routes
    named_route 'theme_images', "/themes/:theme/images/:filename", :controller=>'theme', :action=>'images'
    named_route 'theme_stylesheets', "/themes/:theme/stylesheets/:filename", :controller=>'theme', :action=>'stylesheets'
    named_route 'theme_javascript', "/themes/:theme/javascripts/:filename", :controller=>'theme', :action=>'javascript'
    connect "/themes/*whatever", :controller=>'theme', :action=>'error'
  end

end