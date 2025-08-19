class DotOne::Services::ConversionSoFar
  attr_reader :offer_ids, :affiliate_ids, :cap_type, :time_zone, :cap_earliest_at

  def initialize(**args)
    @offer_ids = args[:offer_ids]
    @affiliate_ids = args[:affiliate_ids]
    @time_zone = args[:time_zone] || TimeZone.current
    @cap_type = args[:cap_type]
    @cap_earliest_at = args[:cap_earliest_at]
    @retries = 0
  end

  def calculate
    return unless date_range = get_date_range.presence

    date_range = date_range.map { |date| date.to_s(:db) }

    selects = [:offer_id]
    selects.push(:affiliate_id) if affiliate_ids.present?

    stats = Stat.stat(selects, [:captured], user_role: :owner)
      .between(*date_range, :captured_at)
      .where(offer_id: offer_ids)

    stats = stats.where(affiliate_id: affiliate_ids) if affiliate_ids.present?

    stats.to_h do |item|
      [selects.map { |select| item[select] }.join('-'), item.captured.to_i]
    end
  rescue Exception => e
    raise e if @retries > 10

    ActiveRecord::Base.connection.reconnect!
    @retries += 1
    retry
  end

  private

  ##
  # Method to determine the date range
  def get_date_range
    return if cap_type.blank?

    if cap_type == OfferCap.cap_type_lifetime_cap
      earliest_time = cap_earliest_at || 2.years.ago
      [time_zone.from_utc(earliest_time), time_zone.from_utc(Time.now)]
    else
      time_zone.local_range(OfferCap.date_range_map[cap_type.to_s])
    end
  end
end
