module DotOne::Errors
  class ApiRequestError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('api_request.base'))
      @payload = payload

      @details = if details.is_a?(Array)
        details.join(', ')
      else
        DotOne::I18n.err(details)
      end
    end
  end
end
