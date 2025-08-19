module DotOne
  module Utils
    module CurrencyConverter
      class << self
        def convert(from, to, value)
          value.to_money(from).exchange_to(to).to_f rescue 0.0
        end

        def convert_from_platform(to, value)
          convert(Currency.platform_code, to, value)
        end

        def generate_rate_map(from = Currency.platform_code)
          rate_map = Currency::AVAILABLE_CURRENCIES.each_with_object({}) do |code, result|
            result[code] = (convert(from, code, 10000) / 10000).round(6)
          end

          rate_map[from] = 1.0
          rate_map.with_indifferent_access
        end

        def convert_to_all(from, value, **options)
          rate_map = options[:rate_map] || generate_rate_map(from)
          rate_map
            .map { |code, rate| [code, rate * value.to_f] }
            .to_h
            .with_indifferent_access
        end

        ##
        # The returned rate is calculated based on usd rate hash
        # provided in the parameter as we don't store all possible
        # currency conversion rates
        def convert_rate(from, to, rate_map = {})
          raise DotOne::Errors::CurrencyError.new({}, 'currency.source_currency_blank') if from.blank?
          raise DotOne::Errors::CurrencyError.new({}, 'currency.target_currency_blank') if to.blank?

          rate_map = generate_rate_map(Currency.default_code) if rate_map.blank?

          if rate_map[from].blank?
            payload = {
              source_currency: from,
              rate_hash: rate_map,
            }
            raise DotOne::Errors::CurrencyError.new(payload, 'currency.source_currency_not_recognized')
          end

          if rate_map[to].blank?
            payload = {
              target_currency: to,
              rate_hash: rate_map,
            }
            raise DotOne::Errors::CurrencyError.new(payload, 'currency.target_currency_not_recognized')
          end

          if rate_map[from].to_f == 0
            0
          else
            rate_map[to].to_f / rate_map[from].to_f
          end
        end
      end
    end
  end
end
