module LocalDateZone
  extend ActiveSupport::Concern
  include DateRangeable

  included do
    cattr_reader :local_date_attributes
  end

  module ClassMethods
    def set_local_date_attributes(*attrs, **options)
      original_timezone = options[:time_zone] || TimeZone.default

      class_variable_set(:@@local_date_attributes, (local_date_attributes.to_a | attrs))

      attrs.flatten.each do |attribute|
        # define local date getter
        define_method("#{attribute}_local") do |timezone = TimeZone.current|
          return if send(attribute).blank?

          value = send(attribute)
          utc = original_timezone.to_utc(value)

          timezone.from_utc(utc).to_date
        end

        # define local date setter
        define_method("#{attribute}_local=") do |*args|
          value = args.flatten[0]
          timezone_or_id = args.flatten[1] || TimeZone.current

          timezone = if timezone_or_id.is_a?(Integer)
            TimeZone.cached_find(timezone_or_id)
          else
            timezone_or_id
          end

          if value.present?
            time = Date.strptime(value.to_s, '%Y-%m-%d')
            utc = timezone.to_utc(time)
            original = original_timezone.from_utc(utc)
            send("#{attribute}=", original)
          else
            send("#{attribute}=", nil)
          end
        end
      end
    end
  end
end
