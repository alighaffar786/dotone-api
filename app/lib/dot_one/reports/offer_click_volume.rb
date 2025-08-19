class DotOne::Reports::OfferClickVolume < DotOne::Reports::Base
  def generate
    DotOne::Cache.fetch(cache_key_name, expires_in: 1.day) do
      date_range = time_zone.local_range(:x_to_y_days_ago, x: 1, y: 7)

      Stat
        .between(*date_range, :recorded_at, time_zone)
        .stat([:offer_id, :date], [:clicks], time_zone: time_zone)
        .group_by(&:offer_id)
        .map do |offer_id, stats|
          [offer_id, convert_to_volume(stats, *date_range)]
        end
        .to_h
    end
  end

  def generate_epc
    DotOne::Cache.fetch(cache_key_name(:epc), expires_in: 1.day) do
      date_range = time_zone.local_range(:x_to_y_days_ago, x: 1, y: 90)

      Stat
        .between(*date_range, :recorded_at, time_zone)
        .stat([:offer_id], [:affiliate_pay_epc], currency_code: currency_code)
        .map do |stat|
          [stat.offer_id, stat.affiliate_pay_epc.round(2)]
        end
        .to_h
    end
  end

  private

  def convert_to_volume(stats, start_at, end_at)
    steps = (start_at.to_date..end_at.to_date).to_a
    result = steps.map { |date| [date, 0] }.to_h

    stats.each do |stat|
      result[stat.date.to_date] = stat.clicks
    end

    result.values
  end
end
