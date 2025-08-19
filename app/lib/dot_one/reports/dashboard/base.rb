# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class Base
    include BooleanHelper
    include ActionView::Helpers::DateHelper

    attr_accessor :network, :time_zone, :currency_code, :params

    def initialize(args)
      @network = args[:network]
      @time_zone = args[:time_zone] || TimeZone.current
      @currency_code = args[:currency_code] || Currency.current_code
      @params = args[:params]
    end

    protected

    def refresh?
      truthy?(params[:refresh])
    end

    def generate(&block)
      clear_cache if refresh?
      return {} unless block_given?

      DotOne::Cache.fetch(cache_key_name, expires_in: 30.minutes, &block)
    end

    def pagination; end

    def stats
      Stat.where(network_id: network_id)
    end

    def offer_ids
      @offer_ids ||= offers.ids
    end

    def offers
      network.offers
    end

    def to_time_ago(date, options = {})
      time_ago_in_words(to_current_time_zone(date, options)) if date.present?
    end

    def to_current_time_zone(date, options = {})
      time_zone.from_utc(date, options)
    end

    def to_utc(date, options = {})
      time_zone.to_utc(date, options)
    end

    def network_id
      @network_id ||= network.id
    end

    def to_current_currency(from, value)
      Currency.converter.convert(from || Currency.platform_code, currency_code, value)
    end

    def days_ago(number)
      rails_time_zone = ActiveSupport::TimeZone[time_zone.gmt_string.to_i]
      number.days.ago.in_time_zone(rails_time_zone).to_date
    end

    def days_ago_in_utc(number)
      (Time.now.utc - number.day).beginning_of_day
    end

    def end_of_today
      Time.now.utc.end_of_day
    end

    def format_data_in_range(data, start_date, end_date)
      (start_date..end_date).to_a.map { |day| [day.to_s, data[day.to_s].presence || 0] }.to_h
    end

    def get_total_in_range(data, start_date, end_date)
      (start_date..end_date).to_a.map { |day| data[day.to_s].presence || 0 }.sum
    end

    def calc_percentage_and_direction(last_week_count, this_week_count)
      if last_week_count == 0
        percentage = 100
        direction = 'up'
      end

      percentage = 0 if last_week_count == 0 && this_week_count == 0
      percentage ||= (last_week_count - this_week_count) / last_week_count.to_f * 100
      direction ||= this_week_count <= last_week_count ? 'up' : 'down'

      {
        value: "#{percentage.abs.ceil(2)}%",
        direction: direction,
      }
    end

    def cache_key_name
      "dashboard_#{network_id}_#{currency_code}_#{time_zone.id}_#{self.class.name.demodulize.underscore}"
    end

    def clear_cache
      Rails.cache.delete(cache_key_name)
    end
  end
end
