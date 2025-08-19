class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ExceptionHandler
  include PaginationHandler
  include BooleanHelper
  include CacheHandler

  before_action :check_per_page_limit

  def ping
    render json: { status: :ok }
  end
end
