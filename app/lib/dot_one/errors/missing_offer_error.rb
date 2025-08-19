module DotOne::Errors
  class MissingOfferError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Missing Offer'))
      @payload = payload
      @details = details
    end
  end
end
