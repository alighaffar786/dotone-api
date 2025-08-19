# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class Visitor < Base
    def generate
      super do
        {
          total_visitors: click_by_countries,
          our_visitors: click_by_devices,
        }
      end
    end

    private

    def click_by_countries
      @click_by_countries ||= begin
        data = stats
          .clicks
          .recorded_at(days_ago_in_utc(365))
          .group(:ip_country)
          .pluck(:ip_country, 'count(ip_country)')
          .to_h

        COUNTRIES.keys.to_h do |country|
          [COUNTRIES[country], data[country.to_s] || 0]
        end
      end
    end

    def click_by_devices
      @click_by_devices ||= stats
        .clicks
        .recorded_at(days_ago_in_utc(365))
        .group(:device_type)
        .pluck(:device_type, 'count(device_type)')
        .to_h
        .except(nil)
    end
  end
end
