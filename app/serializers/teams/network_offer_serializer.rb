class Teams::NetworkOfferSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :conversion_point, :destination_url, :status, :expired_at, :brand_background,
    :true_conv_type, :affiliate_conv_type, :no_expiration, :redirect_url, :conv_types, :short_description,
    :network_id, :category_ids, :translation_stats, :attribution_type, :track_device, :request_count,
    :product_description, :other_info, :target_audience, :suggested_media, :keywords, :earning_meter,
    :offer_name, :package_name, :custom_epc, :manager_insight, :top_traffic_source_ids, :client_offer_name, :client_uniq_id,
    :will_notify_24_hour_paused, :will_notify_48_hour_paused, :approval_method, :captured_time, :captured_time_num_days,
    :published_time, :published_time_num_days, :approved_time, :approved_time_num_days, :enforce_uniq_ip, :skip_order_api?,
    :approval_message, :click_geo_filter, :meta_refresh_redirect, :custom_approval_message, :mixed_affiliate_pay, :mkt_site_id,
    :need_approval, :placement_needed, :do_not_reformat_deeplink_url, :use_direct_advertiser_url,
    :brand_image_url, :brand_image_small_url, :brand_image_medium_url, :brand_image_large_url, :published_date,
    :country_ids, :media_restriction_ids, :click_pixels, :hash_tokens, :min_conv_rate, :max_conv_rate, :min_epc, :max_epc,
    :deeplink_modifier, :whitelisted_destination_urls

  has_many :categories
  has_many :countries
  has_many :media_restrictions
  has_many :group_tags
  has_many :admin_logs, key: :affiliate_logs
  has_many :top_traffic_sources, serializer: AffiliateTag::TopTrafficSourceSerializer
  has_many :offer_conversion_pixels

  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariantSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer
  has_one :offer_cap

  NetworkOffer.dynamic_translatable_attribute_types.each_key do |key|
    has_many "#{key}_translations".to_sym
  end

  def conv_types
    [object.true_conv_type, object.affiliate_conv_type].uniq.compact
  end

  def mkt_site_id
    object.mkt_site&.id
  end
end
