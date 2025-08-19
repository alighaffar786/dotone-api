module DotOne::Errors::PartnerStoreError
  class BlankOfferError < DotOne::Errors::BaseError
    def initialize(payload, details = '')
      super('No Offer Defined')
      @payload = payload
      @details = details
    end
  end

  class NoSetupError < DotOne::Errors::BaseError
    def initialize(payload, details = '')
      super('No Store Setup Defined')
      @payload = payload
      @details = details
    end
  end
end
