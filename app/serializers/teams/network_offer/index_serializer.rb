class Teams::NetworkOffer::IndexSerializer < Base::NetworkOfferSerializer
  attributes :id, :network_id, :name, :brand_image_small_url, :brand_image_url, :affiliate_conv_type, :true_conv_type,
    :destination_url, :earning_meter, :request_count, :translation_stats, :conversion_point, :published_date,
    :min_affiliate_pay, :max_affiliate_pay, :min_affiliate_share, :max_affiliate_share,
    :min_true_pay, :max_true_pay, :min_true_share, :max_true_share, :attribution_type, :track_device, :has_product_api?,
    :click_volume, :epc, :detail_views_last_month, :short_description, :mixed_affiliate_pay

  has_many :categories
  has_many :countries
  has_many :media_restrictions
  has_many :group_tags
  has_many :admin_logs, key: :affiliate_logs

  has_one :network, serializer: Teams::Network::MiniSerializer, if: :can_read_network?
  has_one :default_conversion_step, key: :conversion_step
  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariant::MiniSerializer

  def brand_image_small_url
    object.brand_image_small&.cdn_url
  end

  def click_volume
    instance_options.dig(:click_volumes, object.id) || ([0] * 7)
  end

  def epc
    instance_options.dig(:epcs, object.id).to_f
  end
end
