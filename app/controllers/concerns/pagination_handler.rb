module PaginationHandler
  include CurrentHandler

  protected

  def check_per_page_limit
    raise ExceptionHandler::PaginationMaxLimitReached if params[:per_page].to_i > MAX_PER_PAGE_LIMIT
  end

  def paginate(collection)
    collection.paginate(page: current_page, per_page: current_per_page)
  end

  def array_paginate(collection)
    WillPaginate::Collection.create(current_page, current_per_page, collection.length) do |pager|
      pager.replace collection[pager.offset, pager.per_page].to_a
    end
  end
end
