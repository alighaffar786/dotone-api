module ExceptionHandler
  extend ActiveSupport::Concern

  class PaginationMaxLimitReached < StandardError; end
  class InvalidParams < StandardError; end
  class UpdateError < StandardError; end

  included do
    rescue_from PaginationMaxLimitReached do |_e|
      respond_with({ message: "Max per page limit is #{MAX_PER_PAGE_LIMIT}" }, status: :unprocessable_entity)
    end

    rescue_from CanCan::AccessDenied do |_exception|
      respond_with({ message: 'You are not authorized' }, status: :unauthorized)
    end

    rescue_from ActionController::InvalidAuthenticityToken do |_e|
      respond_with({ message: 'You are not authorized' }, status: :unauthorized)
    end

    rescue_from JWT::DecodeError do |_e|
      respond_with({ message: 'Invalid authorization token' }, status: :unauthorized)
    end

    rescue_from ActiveRecord::RecordNotFound do |_e|
      respond_with({ message: 'Record not found.' }, status: :not_found)
    end

    rescue_from ActiveRecord::RecordNotUnique do |_e|
      respond_with({ message: 'Record already exists.' }, status: :unprocessable_entity)
    end

    rescue_from ActionController::ParameterMissing do |e|
      respond_with({ message: "Parameter `#{e.param}` is missing." }, status: :unprocessable_entity)
    end

    rescue_from UpdateError do |_e|
      respond_with({ message: _e }, status: :unprocessable_entity)
    end

    rescue_from InvalidParams do |_e|
      respond_with({ message: _e }, status: :unprocessable_entity)
    end

    rescue_from DotOne::Errors::BaseError do |e|
      respond_with({ message: e.full_message }, status: :unprocessable_entity)
    end

    rescue_from PG::ConnectionBad do |e|
      respond_with({ message: 'Report is under maintenance every Saturday from 7pm to 7:30pm GTM:00.' }, status: 503)
    end

    rescue_from Rack::Timeout::RequestTimeoutException do
      respond_with({ message: 'Request timeout' }, status: 408)
    end
  end
end
