module DotOne::Errors
  class AccountError < BaseError
    def initialize(payload, details = '', data = nil)
      super(details)
      @payload = payload
      @data = data
    end
  end
end
