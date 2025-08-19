module DotOne::Errors
  class MissingCampaignError < BaseError
    def initialize(payload, details = '')
      super(DotOne::I18n.err('Missing Campaign'))
      @payload = payload
      @details = details
    end
  end
end
