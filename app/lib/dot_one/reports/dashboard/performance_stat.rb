# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class PerformanceStat < Base
    DATE_RANGE_TYPES = {
      day: [:yesterday, :today],
      month: [:last_month, :this_month],
      year: [:last_year, :this_year],
    }

    attr_accessor :date_type, :date_range_types

    def initialize(args)
      super
      @date_type = params[:duration].presence&.to_sym || :day
      @date_range_types = DATE_RANGE_TYPES[@date_type] || DATE_RANGE_TYPES[:day]
    end

    def query_stat(date_range, date_type, aggregate_columns = [])
      stats
        .between(*date_range, date_type, time_zone)
        .stat([], aggregate_columns, currency_code: currency_code, user_role: :network)[0]
    end

    def query_click_stat(date_range)
      query_stat(date_range, :recorded_at, [:clicks])
    end

    def query_pending_conversion(date_range)
      query_stat(date_range, :captured_at, [:pending_conversions])
    end

    def query_confirmed_conversion(date_range)
      query_stat(date_range, :published_at, [:confirmed_conversions])
    end

    def query_order_total(date_range)
      query_stat(date_range, :captured_at, [:order_total])
    end

    def generate
      super do
        result = {}
        growth = {}

        date_range_types.each do |date_range_type|
          date_range = time_zone.local_range(date_range_type)
          if result[:previous]
            result[:current] = generate_by_date_range(date_range)
          else
            result[:previous] = generate_by_date_range(date_range)
          end
        end

        [:clicks, :pending_conversions, :confirmed_conversions, :total_conversions, :order_total].each do |column|
          previous = result[:previous]
          current = result[:current]
          growth[column] = calculate_growth(previous[column], current[column])
        end

        result[:growth] = growth
        result
      end
    end

    def generate_by_date_range(date_range)
      result = {
        clicks: 0,
        pending_conversions: 0,
        confirmed_conversions: 0,
      }

      if click_stat = query_click_stat(date_range)
        result[:clicks] = click_stat.clicks.to_i
      end

      if pending_conversion_stat = query_pending_conversion(date_range)
        result[:pending_conversions] = pending_conversion_stat.pending_conversions.to_i
      end

      if confirmed_conversion_stat = query_confirmed_conversion(date_range)
        result[:confirmed_conversions] = confirmed_conversion_stat.confirmed_conversions.to_i
      end

      result[:total_conversions] = result[:pending_conversions] + result[:confirmed_conversions]
      result[:order_total] = query_order_total(date_range).order_total.to_f
      result
    end

    def calculate_growth(past, present)
      @calculator ||= DotOne::Reports::GrowthCalculator.new(time_zone: time_zone, date_type: date_type)
      @calculator.calculate(past, present)
    end

    private

    def cache_key_name
      "#{super}_#{date_type}"
    end
  end
end
