module DotOne::Errors
  class EmailNotVerifiedError < BaseError
    def initialize(payload, details = '', data = nil)
      super('Email Not Verified')
      @payload = payload
      @details = details
      @data = data
    end
  end
end
