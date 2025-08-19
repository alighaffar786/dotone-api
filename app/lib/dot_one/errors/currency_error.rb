module DotOne::Errors
  class CurrencyError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('currency.base'))
      @payload = payload
      @details = DotOne::I18n.err(details)
    end
  end
end
