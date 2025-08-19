module Track::ExceptionHandler
  extend ActiveSupport::Concern

  included do
    # parent error need to be handled on top
    # to not override the child error
    rescue_from DotOne::Errors::BaseError, PG::ConnectionBad do |e|
      respond_with_error(e.full_message, exception: e)
    end

    rescue_from Rack::Timeout::RequestTimeoutException do |e|
      respond_with_error('Request timeout', status: :request_timeout, exception: e) do |resource, status|
        render plain: resource[:message], status: status
      end
    end

    rescue_from DotOne::Errors::ClickError::InvalidGeoError do |e|
      respond_with_error("Geo Filter: #{e.full_message}") do |resource, status|
        render :geo_filter, status: status
      end
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      respond_with_error(e.full_message, status: :not_found)
    end

    rescue_from DotOne::Errors::ClickError::BlacklistedRefererDomainError, DotOne::Errors::ClickError::BlacklistedSubidError do |e|
      respond_with_error("Traffic source is banned: #{e.full_message}")
    end

    def respond_with_error(message, status: :unprocessable_entity, exception: nil)
      Sentry.capture_exception(exception, extra: params.permit!) if exception

      respond_with({ message: message }, status: status) do |resource, status, **args|
        if block_given?
          yield(resource, status, **args)
        else
          redirect_to_terminal(resource[:message], false)
        end
      end
    end
  end
end
