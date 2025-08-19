module DotOne::Errors
  class MissingAffiliateError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Affiliate Not Found'))
      @payload = payload
      @details = details
    end
  end
end
