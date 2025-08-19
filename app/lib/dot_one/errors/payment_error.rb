module DotOne::Errors::PaymentError
  class OverlappedPaymentError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Overlapped Payment'))
      @payload = payload
    end
  end

  class UnknownAffiliateError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Unknown Affiliate'))
      @payload = payload
    end
  end
end
