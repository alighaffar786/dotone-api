class Teams::AffiliateOfferSerializer < Base::AffiliateOfferSerializer
  attributes :id, :offer_id, :affiliate_id, :offer_variant_status, :created_at

  conditional_attributes :cap_type, :cap_size, :cap_redirect, :cap_earliest_at, :cap_notification_email, :cap_time_zone,
    :conversion_so_far, :approval_status, :status_summary, :status_reason, :reapply_note, :claim_message,
    :deeplink_preview_url, :conversion_pixel_html, :conversion_pixel_s2s, :pixel_suppress_rate, if: :can_read_affiliate?

  conditional_attributes :tracking_url, if: :can_read_affiliate?

  has_many :step_prices, if: :can_read_affiliate?
  has_many :step_pixels, if: :can_read_affiliate?

  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer
  has_one :default_conversion_step, key: :conversion_step, if: :can_read_affiliate?
  has_one :default_step_price, key: :step_price, if: :can_read_affiliate?
  has_one :offer_cap, if: :can_read_affiliate?
  has_one :cap_time_zone_item
end
