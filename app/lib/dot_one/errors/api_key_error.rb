module DotOne::Errors
  class ApiKeyError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('api_key.base'))
      @payload = payload
      @details = DotOne::I18n.err(details)
    end
  end
end
