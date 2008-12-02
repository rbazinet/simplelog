# $Id: production.rb 302 2007-02-02 22:43:14Z garrett $

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes  = true
config.logger = nil

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching = true

require 'bluecloth/lib/bluecloth' # for markdown filtering
require 'redcloth/lib/redcloth'   # for textile filtering
require 'rubypants'               # nice quotes, dashes, etc (smartypants)