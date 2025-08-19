module DotOne::Errors
  class MissingOrderError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Missing Order'))
      @payload = payload
      @details = details
    end
  end
end
