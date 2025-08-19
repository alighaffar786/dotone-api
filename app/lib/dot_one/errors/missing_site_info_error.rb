module DotOne::Errors
  class MissingSiteInfoError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Site Info Not Found'))
      @payload = payload
      @details = details
    end
  end
end
