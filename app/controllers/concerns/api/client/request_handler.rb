module Api::Client::RequestHandler
  include CurrentHandler

  private

  # Translate any incoming time attributes to
  # its corresponding local time attributes allowing
  # consistency that any incoming time parameters will
  # contain local time values
  def assign_local_time_params(time_attributes, given_params = nil)
    current = given_params || params

    if time_attributes.is_a?(Hash)
      time_attributes.each_pair do |model_key, time_attribute_array|
        time_attribute_array.each do |time_attribute|
          if current[model_key] && current[model_key].key?(time_attribute)
            value = current[model_key].delete(time_attribute)
            current[model_key]["#{time_attribute}_local".to_sym] = [value, current_time_zone.id]
          end
        end
      end
    elsif time_attributes.is_a?(Array)
      time_attributes.each do |time_attribute|
        next unless current.key?(time_attribute)

        value = current.delete(time_attribute)
        current["#{time_attribute}_local".to_sym] = [value, current_time_zone.id]
      end
    end
  end

  def assign_forex_value_params(forex_attributes, given_params = nil)
    current = given_params || params

    if forex_attributes.is_a?(Hash)
      forex_attributes.each_pair do |model_key, forex_attribute_array|
        forex_attribute_array.each do |forex_attribute|
          if current[model_key] && current[model_key].key?(forex_attribute)
            current[model_key]["forex_#{forex_attribute}".to_sym] =
              [current[model_key].delete(forex_attribute), current_currency_code]
          end
        end
      end
    elsif forex_attributes.is_a?(Array)
      forex_attributes.each do |forex_attribute|
        next unless current.key?(forex_attribute)

        current["forex_#{forex_attribute}".to_sym] = [current.delete(forex_attribute), current_currency_code]
      end
    end
  end
end
