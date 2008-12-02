# $Id: base_helper.rb 300 2007-02-01 23:01:00Z garrett $

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

module Admin::BaseHelper
  
  # this is a custom version of the error_messages_for method, it's used
  # in preferences to create rails-esque error messages
  def gm_error_messages_for
    if !errors.empty?
      content_tag("div",
      content_tag(
      options[:header_tag] || "h2",
        "#{pluralize(errors.count, "error")} prohibited your preferences from being saved"
        ) +
        content_tag("p", "There were problems with the following fields:") +
        content_tag("ul", errors.full_messages.collect { |msg| content_tag("li", msg) }),
        "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
        )
    else
      ""
    end
  end
  
end