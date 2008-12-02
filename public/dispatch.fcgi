#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
require 'fcgi_handler'

# if SL_CONFIG[:DREAMHOST] == 'yes'
#   class RailsFCGIHandler
#     private
#       def frao_handler(signal)
#         dispatcher_log :info, "asked to terminate immediately"
#         dispatcher_log :info, "frao handler working its magic!"
#         restart_handler(signal)
#       end
#       alias_method :exit_now_handler, :frao_handler
#   end
#   RailsFCGIHandler.process! nil, 50
# else
  RailsFCGIHandler.process!
# end