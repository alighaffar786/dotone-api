module DotOne::Errors
  class AwsError < BaseError
    def initialize(payload, details = '')
      message = [payload[:code], details].compact.join(': ')
      super(message)
      @payload = payload
      @details = details
    end

    def full_message
      [@payload, @details].compact.join(': ')
    end
  end
end
