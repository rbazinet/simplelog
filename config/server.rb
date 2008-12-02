# $Id: server.rb 300 2007-02-01 23:01:00Z garrett $
#
#        ,--.                 ,--.       ,--.              
#  ,---. `--',--,--,--. ,---. |  | ,---. |  | ,---.  ,---. 
# (  .-' ,--.|        || .-. ||  || .-. :|  || .-. || .-. |
# .-'  `)|  ||  |  |  || '-' '|  |\   --.|  |' '-' '' '-' '
# `----' `--'`--`--`--'|  |-' `--' `----'`--' `---' .`-  / 
#                      `--'                         `---'
#
# SimpleLog - A simple Ruby on Rails weblog application
# Copyright (c) 2006-2007 Garrett Murray
#
# This software is released under the GPL license. See LICENSE file for details.
#
# See README for installation instructions!

##################################################################
# BE SURE TO RESTART YOUR WEB SERVER AFTER YOU MODIFY THIS FILE! #
##################################################################

# Are you using Dreamhost?
  SL_CONFIG[:DREAMHOST]     = 'no'  # (yes or no) are you deploying this app on a DH server? (see DH_README for details)
# Database type
  SL_CONFIG[:DB_TYPE_MYSQL] = 'yes' # (yes or no) are you using mysql as the database type?

# Set your mail configuration for comment notification (optional)
  ActionMailer::Base.server_settings = {
    :address        => '',
    :port           => 25, 
    :domain         => '',
    :user_name      => '',
    :password       => '',
    :authentication => :login
  }