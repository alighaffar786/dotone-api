class Advertisers::NetworkOfferSerializer < Base::NetworkOfferSerializer
  attributes :id, :network_id, :name, :short_description, :published_date, :brand_background,
    :product_description, :target_audience, :suggested_media, :other_info,
    :captured_time, :captured_time_num_days, :published_time, :published_time_num_days, :approved_time,
    :approved_time_num_days, :attribution_type, :track_device, :deeplinkable?, :has_ad_link?,
    :has_data_feed?, :need_approval, :placement_needed, :conversion_type, :total_missing_orders, :detail_views_last_month,
    :pending_transactions, :payouts, :status, :total_active_affiliates, :total_active_image_creatives,
    :total_active_text_creatives, :brand_image_medium_url

  has_many :categories
  has_many :countries
  has_many :media_restrictions
  has_many :offer_variants
  has_many :ordered_conversion_steps, key: :conversion_steps
  has_one :offer_cap

  def pending_transactions
    instance_options[:pending_conversion_counts].fetch(object.id, 0)
  end

  def total_missing_orders
    instance_options[:missing_order_counts].fetch(object.id, 0)
  end

  def total_active_affiliates
    instance_options[:active_affiliate_counts].fetch(object.id, 0)
  end

  def total_active_image_creatives
    instance_options[:active_image_creative_counts].fetch(object.id, 0)
  end

  def total_active_text_creatives
    instance_options[:active_text_creative_counts].fetch(object.id, 0)
  end
end
