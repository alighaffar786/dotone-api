module Forexable
  extend ActiveSupport::Concern

  included do
    cattr_reader :forexable_attributes

    def current_currency_code
      if respond_to?(:original_currency)
        original_currency || Currency.platform_code
      elsif respond_to?(:currency)
        currency&.code || Currency.platform_code
      else
        Currency.platform_code
      end
    end

    def currency_rate_map
      return @currency_rate_map if @currency_rate_map.present?

      @currency_rate_map = if respond_to?(:forex)
        # NOTE: forex is a json column. Should stop adding String value.
        if forex.is_a?(String)
          begin
            JSON.parse(forex)
          rescue StandardError
            {}
          end
        else
          forex.presence
        end
      end

      @currency_rate_map = Currency.converter.generate_rate_map(current_currency_code) if @currency_rate_map.blank?
      @currency_rate_map
    end
  end

  module ClassMethods
    def set_forexable_reader_attributes(*attrs, **options)
      class_variable_set(:@@forexable_attributes, (forexable_attributes.to_a | attrs))

      allow_nil = options[:allow_nil] == true

      attrs.flatten.each do |attribute|
        # Getter method
        define_method "forex_#{attribute}" do |currency_code = Currency.current_code|
          value = send(attribute)
          return if value.nil? && allow_nil

          value = value.to_f

          return value if current_currency_code == currency_code

          rate = Currency.rate(current_currency_code, currency_code, currency_rate_map)
          (rate * value).round(2)
        rescue DotOne::Errors::BaseError => e
          ::Rails.logger.warn "[Forexable.set_forexable_attributes: #{attribute}] #{e.full_message}"
          value
        end

        define_method "platform_#{attribute}" do
          send("forex_#{attribute}", Currency.platform_code)
        end
      end
    end

    def set_forexable_attributes(*attrs, **options)
      set_forexable_reader_attributes(*attrs, **options)

      attrs.flatten.each do |attribute|
        # Setter method
        define_method "forex_#{attribute}=" do |*args|
          value = args.flatten[0]
          currency_code = args.flatten[1]

          if value.present?
            return if currency_code.blank?

            rate = Currency.rate(currency_code, current_currency_code, currency_rate_map)
            send("#{attribute}=", (rate * value.to_f).round(2))
          else
            send("#{attribute}=", nil)
          end
        rescue DotOne::Errors::BaseError => e
          ::Rails.logger.warn "[Forexable.set_forexable_attributes: #{attribute}] #{e.full_message}"
          send("#{attribute}=", value)
        end
      end
    end
  end
end
