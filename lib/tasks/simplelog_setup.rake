# $Id: simplelog_setup.rake 300 2007-02-01 23:01:00Z garrett $

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
# this rake task will set up the DBs, run tests, and prevent unncessary rake errors
# due to the bug in the schema creator which causes fulltext indexes to come through
# incorrectly. this is the primary way to install simplelog's necessary db stucture.
#
# please avoid running rake itself, since it will report false errors.
#

namespace :simplelog do

  namespace :install do
    
    desc "Install SimpleLog DB and RUN TESTS after configuring database.yml"
    task :tested => :environment do
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:test:clone_structure'].invoke rescue save = false # this will create a schema too
      Rake::Task['db:test:prepare'].invoke rescue save = false
      Rake::Task['test'].invoke rescue save = false # part of default
    end
    
  end
  
end