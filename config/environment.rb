# $Id: environment.rb 328 2007-02-08 22:50:30Z garrett $

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

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Some storage for application-wide stuff and constants
SL_CONFIG = Hash.new
@@stored_prefs = Hash.new
@@stored_blacklist = Array.new

Rails::Initializer.run do |config|
  # Use the database for sessions instead of the file system
  config.action_controller.session_store = :active_record_store
  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  # Use Active Record's schema dumper instead of SQL when creating the test database
  config.active_record.schema_format = :ruby
end

##################################################################
# Don't change anything below this line! Seriously!              #
##################################################################

  # Logging settings (warnings only, otherwise logs get REALLY big)
  RAILS_DEFAULT_LOGGER.level = Logger::WARN

  # SimpleLog version
  SL_CONFIG[:VERSION] = '2.0.2'
  # Where to check for updates
  SL_CONFIG[:UPDATES_URL] = 'simplelog.net/updates/version.xml'
  # Where to get the blacklist
  SL_CONFIG[:BLACKLIST_URL] = 'simplelog.net/blacklist/current/'
  # Used in cookies
  SL_CONFIG[:USER_EMAIL_COOKIE] = '_sl_email'
  SL_CONFIG[:USER_HASH_COOKIE] = '_sl_hash'
  
  # we load our site's config now
  require 'server.rb'

  # Some required stuff (there are additional requires in the environment sub files)
  require 'taggable'      # acts as taggable is required
  require 'htmlentities'  # useful string extension
  require 'cgi'           # we use this in places
  require 'digest/sha1'   # for password hashing
  require 'digest/md5'    # for creating MD5 hashes (gravatar)