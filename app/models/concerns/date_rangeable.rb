module DateRangeable
  extend ActiveSupport::Concern

  included do
    ##
    # Method to query the including active record based on
    # the date range.
    # This method assumes start_at and end_at using local timezone.
    # args[0] - start_at
    # args[1] - end_at
    # args[2] - date type/column name
    # args[3] - time zone (optional. If blank, it will use the current time zone)
    scope :between, -> (*args, **options) {
      start_at = args[0].is_a?(String) ? Date.parse(args[0]) : args[0]
      end_at = args[1].is_a?(String) ? Date.parse(args[1]) : args[1]
      column_name = args[2].presence || :recorded_at
      time_zone = args[3].presence || TimeZone.current
      table_name = args[4].presence || self.table_name
      column = "#{table_name}.#{column_name}"

      start_at_utc = time_zone.to_utc(start_at.beginning_of_day).to_s(:db) if start_at.present?
      end_at_utc = time_zone.to_utc(end_at.end_of_day).to_s(:db) if end_at.present?

      if start_at_utc.present? && end_at_utc.present?
        where("#{column} >= ? AND #{column} <= ?", start_at_utc, end_at_utc)
      elsif options[:any] && start_at_utc.present?
        where("#{column} >= ?", start_at_utc)
      elsif options[:any] && end_at_utc.present?
        where("#{column} <= ?", end_at_utc)
      end
    }
  end
end
