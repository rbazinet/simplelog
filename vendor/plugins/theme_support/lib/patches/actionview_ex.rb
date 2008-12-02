# $Id: actionview_ex.rb 145 2006-07-24 19:18:02Z garrett $

# Extending <tt>ActionView::Base</tt> to support rendering themes
module ActionView
   # <tt>ThemeError</tt> is thrown when <tt>force_liquid</tt> is true, and 
   # a <tt>.liquid</tt> template isn't found.
   class ThemeError < StandardError
   end
   
   # Extending <tt>ActionView::Base</tt> to support rendering themes
   class Base
      alias_method :__render_file, :render_file

      # Overrides the default <tt>Base#render_file</tt> to allow theme-specific views
      def render_file(template_path, use_full_path = true, local_assigns = {})
         search_path = [
            "../themes/#{controller.current_theme}/views",      # for components
            "../../themes/#{controller.current_theme}/views",   # for normal views
            "../../themes/#{controller.current_theme}",         # for layouts
            "."                                                 # fallback
         ]

         if use_full_path
            search_path.each do |prefix|
               theme_path = prefix +'/'+ template_path
               begin
                  template_extension = pick_template_extension(theme_path)
                  
                  # Prevent .rhtml (or any other template type) if force_liquid == true
                  if controller.force_liquid_template and 
                     template_extension.to_s != 'liquid' and 
                     prefix != '.'
                     raise ThemeError.new("Template '#{template_path}' must be a liquid document")
                  end
                  
                  local_assigns['active_theme'] = controller.current_theme unless controller.current_theme.nil? 
               rescue ActionView::ActionViewError => err
                  next
               rescue ThemeError => err
                  # Should it raise an exception, or just call 'next' and revert to
                  # the default template?
                  raise err
               end
               return __render_file(theme_path, use_full_path, local_assigns)
            end
         else
            __render_file(template_path, use_full_path, local_assigns)
         end
      end
   end
end
