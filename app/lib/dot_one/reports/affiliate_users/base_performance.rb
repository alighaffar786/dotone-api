module DotOne::Reports::AffiliateUsers
  class BasePerformance
    attr_accessor :weeks, :start_date, :end_date, :date_range_in_utc

    def initialize
      # Get the past 4 week ranges.
      # The function returns ranges (in ascending order) that include this week, so
      # we need to exclude it
      @weeks = TimeZone.week_ranges_past_n_weeks(5, :friday).reverse[1, 4]
    end

    def self.build_report
      new.build_report
    end

    def build_report
      weeks.map do |week|
        set_date_range(week)

        {
          week: week,
          week_data: week_data,
        }
      end
    end

    def week_data
      raise NoMethodError, 'Implement week_date method in child class'
    end

    def set_date_range(date_range)
      time_zone = TimeZone.platform
      @start_date = time_zone.to_utc(date_range.first.beginning_of_day).to_s(:db)
      @end_date = time_zone.to_utc(date_range.last.end_of_day).to_s(:db)
      @date_range_in_utc = [
        time_zone.to_utc(date_range.first.beginning_of_day),
        time_zone.to_utc(date_range.last.end_of_day),
      ]
    end

    def query_by_date_range(klass, column, start_at = nil, end_at = nil)
      klass.where("#{klass.table_name}.#{column} BETWEEN ? AND ?", (start_at || start_date), (end_at || end_date))
    end

    def query_by_date_range_sql(klass, column, start_at = nil, end_at = nil)
      query_by_date_range(klass, column, start_at, end_at).to_sql
    end

    def query_by_end_date(klass, column)
      klass.where("#{klass.table_name}.#{column} <= ?", end_date)
    end
  end
end
