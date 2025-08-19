module DotOne::Errors::TransactionError
  class ApprovedStateModificationError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('data.transaction_is_already_approved'))
      @payload = payload
    end
  end

  class CapExceededError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Cap Exceeded'))
      @payload = payload
    end
  end

  class ConversionExpiredError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Conversion Expired'))
      @payload = payload
    end
  end

  class FinalStateModificationError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Final State Modification'))
      @payload = payload
    end
  end

  class MissingTransactionError < DotOne::Errors::BaseError
    def initialize(payload)
      super(DotOne::I18n.err('Missing Transaction'))
      @payload = payload
    end
  end
end
