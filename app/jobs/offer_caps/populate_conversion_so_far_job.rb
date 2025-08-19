class OfferCaps::PopulateConversionSoFarJob < MaintenanceJob
  def perform
    return if Rails.cache.read(cache_name).present?

    Rails.cache.write(cache_name, 1, expires_in: 2.hours)

    populate_conversion_for_offer_caps
    populate_conversion_for_campaigns

    Rails.cache.delete(cache_name)
  rescue Exception => e
    Rails.cache.delete(cache_name)
    raise e
  end

  def populate_conversion_for_offer_caps
    OfferCap
      .select('offer_caps.*, time_zones.id AS time_zone_id')
      .joins(offer: [network: :time_zone])
      .cap_defined
      .where(offers: NetworkOffer.active)
      .find_in_batches(batch_size: 500) do |offer_cap_per_cap_types|
        offer_cap_per_cap_types.group_by(&:cap_type).each do |cap_type, offer_cap_per_time_zones|
          offer_cap_per_time_zones.group_by(&:time_zone_id).each do |time_zone_id, offer_cap_per_earliest_ats|
            time_zone = TimeZone.cached_find(time_zone_id)

            offer_cap_per_earliest_ats.group_by(&:cap_earliest_at).each do |earliest_at, offer_caps|
              offer_cap_map = offer_caps.index_by(&:offer_id)

              calculator = DotOne::Services::ConversionSoFar.new(
                offer_ids: offer_cap_map.keys,
                cap_type: cap_type,
                time_zone: time_zone,
                cap_earliest_at: earliest_at,
              )
              conversion_map = calculator.calculate

              conversion_map.each do |offer_id, captured|
                offer_cap_map[offer_id]&.update(conversion_so_far: captured)
              end
            end
          end
        end
    end
  end

  def populate_conversion_for_campaigns
    AffiliateOffer
      .active
      .cap_defined
      .find_in_batches(batch_size: 500) do |campaign_per_cap_types|
        campaign_per_cap_types.group_by(&:cap_type).each do |cap_type, campaign_per_time_zones|
          campaign_per_time_zones.group_by(&:cap_time_zone).each do |time_zone_id, campaign_per_earliest_ats|
            time_zone = TimeZone.cached_find(time_zone_id)

            campaign_per_earliest_ats.group_by(&:cap_earliest_at).each do |earliest_at, campaigns|
              campaign_map = campaigns.index_by { |campaign| [campaign.offer_id, campaign.affiliate_id].join('-') }

              calculator = DotOne::Services::ConversionSoFar.new(
                offer_ids: campaigns.map(&:offer_id),
                affiliate_ids: campaigns.map(&:affiliate_id),
                time_zone: time_zone,
                cap_type: cap_type,
                cap_earliest_at: earliest_at,
              )
              conversion_map = calculator.calculate

              conversion_map.each do |key, captured|
                campaign_map[key]&.conversion_so_far = captured
              end
            end
          end
        end
    end
  end

  def cache_name
    'populate_conversion_so_far'
  end
end
