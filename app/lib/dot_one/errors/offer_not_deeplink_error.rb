module DotOne::Errors
  class OfferNotDeeplinkError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Offer Not Deeplink'))
      @payload = payload
      @details = details
    end
  end
end
