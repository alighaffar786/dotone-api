class DotOne::Reports::GrowthCalculator
  attr_reader :time_zone, :date_type

  def initialize(params)
    @time_zone = params[:time_zone] || TimeZone.current
    @date_type = params[:date_type].presence&.to_sym || :day
  end

  def calculate(past, present)
    s1 = time_zone.to_utc(time_zone.from_utc(Time.now.utc).send("beginning_of_#{date_type}"))
    s2 = Time.now.utc
    current_hour_count = (s2 - s1) / 1.hour
    total_complete_hours = case date_type
    when :day
      24
    when :month
      (Time.now - 1.month).end_of_month.day * 24
    when :year
      (Time.now - 1.year).end_of_year.yday * 24
    end

    if past.to_f == 0
      present.to_f * 100
    elsif present.to_f == 0
      -(past.to_f * 100)
    else
      avg_stat = past.to_f / total_complete_hours
      total_stat = avg_stat * current_hour_count
      ((present.to_f - total_stat) / total_stat) * 100
    end
  end
end
