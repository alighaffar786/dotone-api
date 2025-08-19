module DotOne::Errors
  class InvalidDataError < BaseError
    def initialize(payload, details = '', attribute = nil)
      super(DotOne::I18n.err('data.base'))

      @payload = payload
      @details = DotOne::I18n.err(details, attribute: attribute)
    end
  end
end
