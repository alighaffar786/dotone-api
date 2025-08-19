class Teams::NetworkOffer::RecentSerializer < Base::NetworkOfferSerializer
  attributes :id, :network_id, :name, :brand_image_small_url, :destination_url, :product_description, :approval_message,
    :min_true_pay, :max_true_pay, :min_true_share, :max_true_share, :conversion_step_label,
    :min_affiliate_pay, :max_affiliate_pay, :min_affiliate_share, :max_affiliate_share, :mixed_affiliate_pay

  has_many :categories
  has_many :countries
  has_many :media_restrictions

  has_one :default_offer_variant, key: :offer_variant, serializer: Teams::OfferVariant::MiniSerializer
  has_one :network, serializer: Teams::Network::MiniSerializer

  def conversion_step_label
    object.default_conversion_step&.t_label
  end
end
