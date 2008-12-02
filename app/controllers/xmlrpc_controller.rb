# $Id: xmlrpc_controller.rb 300 2007-02-01 23:01:00Z garrett $

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

class XmlrpcController < ApplicationController
  
  #
  # the xml-rpc controller layers the APIs for modifying this weblog
  # with a weblogging client, see README for instructions
  #
  
  web_service_dispatching_mode :layered
  web_service :metaWeblog,  MetaWeblogService.new
  web_service :mt,          MovableTypeService.new
  web_service :blogger,     BloggerService.new
  
  alias xmlrpc api
  
end