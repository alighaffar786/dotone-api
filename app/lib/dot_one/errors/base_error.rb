module DotOne::Errors
  class BaseError < StandardError
    attr_reader :payload, :details, :data

    def full_message
      msg = [@payload, message].compact.join(': ')
      if @details.present?
        # Clean up due to YAML
        @details = @details.gsub(/\n/, ' ')
        return [msg.strip, @details].join('. ')
      end
      msg
    end
  end
end
