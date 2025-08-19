##
# Error object that represents
# validation error caused by ActiveRecord
module DotOne::Errors
  class RecordValidationError < BaseError
    def initialize(payload, record)
      super(DotOne::I18n.err('data.base'))

      @payload = payload
      @details = []

      record.errors.messages.each_pair do |attribute, message|
        @details << [attribute, message].join(': ')
      end

      @details = @details.join(', ')
    end
  end
end
