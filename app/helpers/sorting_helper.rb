# $Id: sorting_helper.rb 285 2007-01-24 23:49:56Z garrett $

module SortingHelper
  
  class Sorter

    def initialize(controller, columns, sort, order = 'ASC', default_sort = 'id', default_order = 'ASC')
      sort            = default_sort unless columns.include? sort
      order           = default_order unless ['ASC', 'DESC'].include? order
      @controller     = controller
      @columns        = columns
      @sort           = sort
      @order          = order
      @default_sort   = default_sort
      @default_order  = default_order
    end

    def to_sql
      @sort + ' ' + @order
    end
    
    def this_col(col)
      return (col == @sort)
    end
    
    def di(col, show_blank = true)
      if col == @sort
        return '&nbsp;<img src="' + Site.full_url + '/images/admin/arrow_' + (@order == 'DESC' ? 'down' : 'up') + '.gif" width="8" height="7" alt="" class="direction_arrow" />'
      else
        return (show_blank ? '&nbsp;<img src="' + Site.full_url + '/images/admin/t.gif" width="8" height="7" alt=""/>' : '')
      end
    end

    def to_link(column, params = {})
      column = @default_sort unless @columns.include?(column)
      if column == @sort
        order = ('ASC' == @order ? 'DESC' : 'ASC')
      else
        order = @default_order
      end
      { :params => { 'sort' => column, 'order' => order }.merge(params) }
    end

  end

end