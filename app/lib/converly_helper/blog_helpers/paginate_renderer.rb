##
# Used to render custom pagination for skin
# using radius gem
require 'will_paginate/view_helpers/action_view'

module ConverlyHelper::BlogHelpers

  class PaginateRenderer <  WillPaginate::ActionView::LinkRenderer

    attr_accessor :pagination_container_class
    attr_accessor :pagination_previous_page
    attr_accessor :pagination_next_page
    attr_accessor :pagination_current_page_number
    attr_accessor :pagination_page_number

    def container_attributes
      { class: self.pagination_container_class }
    end

    def page_number(page)
      if page == current_page
        self.pagination_current_page_number.gsub("{url}", url(page)).gsub("{number}", page.to_s)
      else
        self.pagination_page_number.gsub("{url}", url(page)).gsub("{number}", page.to_s)
      end
    end

    def previous_page
      num = @collection.current_page > 1 && @collection.current_page - 1
      if num
        self.pagination_previous_page.gsub("{url}", url(num))
      else
        self.pagination_previous_page.gsub("{url}", "javascript:;")
      end
    end

    def next_page
      num = @collection.current_page < total_pages && @collection.current_page + 1
      if num
        self.pagination_next_page.gsub("{url}", url(num))
      else
        self.pagination_next_page.gsub("{url}", "javascript:;")
      end
    end

  end
end
