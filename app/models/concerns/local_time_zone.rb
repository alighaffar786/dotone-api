module LocalTimeZone
  extend ActiveSupport::Concern
  include DateRangeable

  included do
    cattr_reader :local_time_attributes
  end

  module ClassMethods
    def set_local_time_reader_attributes(*attrs)
      class_variable_set(:@@local_time_attributes, (local_time_attributes.to_a | attrs))

      attrs.flatten.each do |attribute|
        define_method("#{attribute}_local") do |timezone = TimeZone.current|
          return if send(attribute).blank?

          # As of 2022-07-07, the default argument does not really work
          timezone ||= TimeZone.current

          timezone.from_utc(send(attribute))
        end
      end
    end

    def set_local_time_attributes(*attrs)
      # Define local time getter
      set_local_time_reader_attributes(*attrs)

      attrs.flatten.each do |attribute|
        # Define local time setter
        define_method("#{attribute}_local=") do |*args|
          value, timezone_or_id = args.flatten

          timezone = if timezone_or_id.is_a?(Integer)
            TimeZone.cached_find(timezone_or_id)
          else
            timezone_or_id
          end

          timezone ||= TimeZone.current

          if value.present?
            time = DateTime.parse(value.to_s.gsub(/凌晨|中午|下午|上午/, '中午' => 'AM', '凌晨' => 'PM', '下午' => 'PM', '上午' => 'AM'))
            send("#{attribute}=", timezone.to_utc(time))
          else
            send("#{attribute}=", nil)
          end
        end
      end
    end
  end
end
