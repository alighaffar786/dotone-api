class Affiliates::NetworkOffer::FeaturedSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :brand_image_url, :conversion_step_label, :min_affiliate_pay, :max_affiliate_pay,
    :min_affiliate_share, :max_affiliate_share, :mixed_affiliate_pay

  def brand_image_url
    if image_size
      object.send("brand_image_#{image_size}")&.cdn_url
    else
      object.brand_image_large&.cdn_url
    end
  end

  def conversion_step_label
    object.default_conversion_step.t_label
  end

  def image_size
    instance_options[:image_size]
  end
end
