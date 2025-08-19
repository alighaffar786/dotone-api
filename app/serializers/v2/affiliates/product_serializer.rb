class V2::Affiliates::ProductSerializer < Base::ProductSerializer
  attributes :client_id_value, :universal_id_value, :title, :description_1, :description_2, :brand, :category_1,
    :category_2, :category_3, :product_url, :is_new, :is_promotion, :promo_start_at, :promo_end_at, :promo_end_at, :inventory_status,
    :created_at, :updated_at, :locale, :currency, :uniq_key, :offer_id, :prices, :images, :additional_attributes,
    :tracking_url

  def tracking_url
    return if campaign.blank?

    product_url = DotOne::Utils::Encryptor.encrypt(object.product_url)
    campaign.to_tracking_url(t: product_url, t_encrypted: 'true')
  end

  def campaign
    instance_options[:campaign]
  end
end
