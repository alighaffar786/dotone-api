class TimeZone < DatabaseRecords::PrimaryRecord
  include ModelCacheable
  include StaticTranslatable

  module Translation
    module Scopes
      GMT_STRING = [:predefined, :models, :time_zone, :gmt_string]
      GMT_STRING_SHORT = [:predefined, :models, :time_zone, :gmt_string_short]
    end
  end

  has_many :affiliate_users, inverse_of: :time_zone, dependent: :nullify
  has_many :affiliates, inverse_of: :time_zone, dependent: :nullify
  has_many :networks, inverse_of: :time_zone, dependent: :nullify
  has_many :users, inverse_of: :time_zone, dependent: :nullify
  has_many :affiliate_offers, foreign_key: :cap_time_zone, inverse_of: :cap_time_zone_item, dependent: :nullify

  set_static_translatable_attributes :gmt_string, :gmt_string_short

  alias_attribute :gmt_string_short, :gmt_string

  def self.default
    @default ||= cached_find_by(gmt: '0.0') || new(name: 'Default', gmt: 0.00)
  end

  def self.platform
    @platform ||= DotOne::Setup.platform_time_zone || default
  end

  def self.current
    DotOne::Current.time_zone
  end

  def self.day_ranges_past_n_days(num_of_days)
    days = []

    d = Date.today - num_of_days.days

    while d <= Date.today
      current_range = [d, d]
      days << current_range
      d += 1.day
    end

    days
  end

  def self.week_ranges_past_n_weeks(num_of_weeks, start_day = :monday)
    weeks = []

    d = Date.today - num_of_weeks.weeks

    while d <= Date.today
      current_range = [
        d.beginning_of_week(start_day),
        d.end_of_week(start_day),
      ]
      weeks << current_range
      d += 1.week
    end

    weeks
  end

  def self.month_ranges_past_n_months(num_of_months)
    return [] if num_of_months <= 0

    months = []

    d = Date.today - num_of_months.month

    times = 0

    while times <= num_of_months
      current_range = [
        d.beginning_of_month,
        d.end_of_month,
      ]
      months << current_range
      d += 1.month
      times += 1
    end
    months
  end

  def self.quarter_ranges_past_n_quarters(num_of_quarters)
    quarters = []

    num_of_quarters.downto(0).each do |offset|
      date = Date.today << (offset * 3)
      quarters << [date.beginning_of_quarter, date.end_of_quarter]
    end

    quarters
  end

  def convert(utc_time)
    utc_time.getlocal(gmt_string)
  end

  def from_utc(utc_time, options = {})
    return if utc_time.blank?
    return utc_time if utc_time.is_a?(DateTime) && utc_time.utc_offset != 0

    format = options[:format] || '%Y-%m-%d'
    utc_time = utc_time.to_time if utc_time.is_a?(DateTime)
    utc_time = Time.strptime(utc_time, format) if utc_time.is_a?(String)
    utc_time = Time.utc(utc_time.year, utc_time.month, utc_time.day, utc_time.hour, utc_time.min, utc_time.sec)
    utc_time = utc_time.getlocal(gmt_string)
    utc_time = utc_time.to_date if options[:to_date] == true
    utc_time
  end

  def to_utc(local_time, options = {})
    return if local_time.blank?

    local_time = local_time.to_time if local_time.is_a?(DateTime)

    if local_time.is_a?(String)
      # List out all possible date(time) format
      # to try
      formats = if options[:format].present?
        [options[:format]]
      else
        ['%Y-%m-%d %H:%M:%S', '%Y-%m-%d']
      end

      formats.each do |f|
        local_time = Time.strptime(local_time, f)
        break
      rescue ArgumentError
        next
      end
    end

    new_time = local_time - gmt.to_i.hour

    Time.utc(new_time.year, new_time.month, new_time.day, new_time.hour, new_time.min, new_time.sec)
  end

  def local_date_range_string(type = :today)
    range = local_range(type)
    range.map { |x| x.to_date.to_s }
  end

  def local_range(type = :today, options = {})
    local_time = from_utc(DateTime.now.utc)
    determine_range(local_time, type, options)
  end

  # Returns array of TimeWithZone objects representing
  # the start and end of previous day/week/month/period
  # and end of current_period
  def local_time_adjacent_periods(period = :day)
    rails_time_zone = ActiveSupport::TimeZone[gmt_string.to_i]
    end_time = Time.now.in_time_zone(rails_time_zone)

    if period == :week
      start_time = (end_time - 1.week).beginning_of_week
      mid_time = start_time + 1.week
    elsif period == :month
      start_time = (end_time - 1.month).beginning_of_month
      mid_time = start_time + 1.month
    elsif period == :quarter
      start_time = (end_time - 3.months).beginning_of_quarter
      mid_time = start_time + 3.months
    else
      start_time = (end_time - 1.day).beginning_of_day
      mid_time = start_time + 1.day
    end

    [start_time, mid_time, end_time]
  end

  ##
  # Get local date range given period group with a date sample.
  def period_group_to_local_range(local_time_string, period_group)
    period_group = if period_group == :day
      :today
    elsif period_group == :week
      :this_week
    elsif period_group == :month
      :this_month
    end

    local_time = from_utc(to_utc(local_time_string))
    determine_range(local_time, period_group)
  end

  # offset is the distance ot this timezone to the UTC.
  # UTC +08:00 has an offset of -08:00
  # UTC -04:00 has an offset of +04:00
  def offset_string
    if gmt_string.include?('-')
      gmt_string.gsub('-', '+')
    else
      gmt_string.gsub('+', '-')
    end
  end

  def now
    convert(Time.current)
  end

  private

  ##
  # Helper to determine the range given a date and
  # type of range.
  def determine_range(local_time, period_group = :today, options = {})
    range = []

    case ConstantProcessor.to_method_name(period_group)
    when :today
      base = local_time
      range << base.beginning_of_day
      range << base.end_of_day
    when :yesterday
      base = local_time - 1.day
      range << base.beginning_of_day
      range << base.end_of_day
    when :this_week
      base = local_time
      range << base.beginning_of_week
      range << base.end_of_week
    when :this_month
      base = local_time
      range << base.beginning_of_month
      range << base.end_of_month
    when :last_month
      base = local_time - 1.month
      range << base.beginning_of_month
      range << base.end_of_month
    when :last_7_days
      range << (local_time - 6.day).beginning_of_day
      range << local_time.end_of_day
    when :last_14_days
      range << (local_time - 13.day).beginning_of_day
      range << local_time.end_of_day
    when :last_30_days
      range << (local_time - 29.day).beginning_of_day
      range << local_time.end_of_day
    when :last_60_days
      range << (local_time - 59.day).beginning_of_day
      range << local_time.end_of_day
    when :last_90_days
      range << (local_time - 89.day).beginning_of_day
      range << local_time.end_of_day
    when :last_6_months
      range << (local_time - 6.months).beginning_of_day
      range << local_time.end_of_day
    when :last_12_months
      range << (local_time - 1.year).beginning_of_day
      range << local_time.end_of_day
    when :this_year
      range << local_time.beginning_of_year
      range << local_time.end_of_year
    when :last_year
      base = local_time - 1.year
      range << base.beginning_of_year
      range << base.end_of_year
    when :lifetime
      range << (local_time - 2.year)
      range << local_time.end_of_day
    when :x_to_y_days_ago
      x = options[:x]
      y = options[:y]
      range << (y.blank? ? nil : (local_time - y.to_i.days))
      range << (x.blank? ? local_time : (local_time - x.to_i.days))
    end

    range
  end
end
