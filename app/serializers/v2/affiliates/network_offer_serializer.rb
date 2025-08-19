class V2::Affiliates::NetworkOfferSerializer < Base::NetworkOfferSerializer
  include DotOne::Api::V2Helper

  attributes :id, :name, :preview_url, :approval_method, :captured_time, :published_time, :approved_time,
    :has_expiration, :expiration_time, :conversion_type, :short_description, :target_audience,
    :suggested_media, :other_info, :disclaimer, :default_tracking_url, :commission_range, :status, :package_name,
    :deeplink, :categories, :countries, :restrictions, :brand_image_url

  conditional_attributes :cap_type, :cap_size, if: -> { object.offer_cap.present? }

  has_many :offer_variants

  def approval_method
    t('approval_method', object.approval_method) if object.approval_method
  end

  def captured_time
    conversion_time(object.captured_time, object.captured_time_num_days)
  end

  def published_time
    conversion_time(object.published_time, object.published_time_num_days)
  end

  def approved_time
    if object.payment_received? || current_user.approval_method == Offer.approval_method_payment_received
      DotOne::I18n.st('After Advertiser Payment')
    else
      conversion_time(object.approved_time, object.approved_time_num_days)
    end
  end

  def status
    return object.status if object.default_offer_variant.paused? || object.default_offer_variant.suspended?
  end

  def categories
    object.categories.map(&:t_name)
  end

  def countries
    object.countries.map(&:t_name)
  end

  def restrictions
    object.media_restrictions.map(&:t_name)
  end

  def preview_url
    object.destination_url
  end

  def has_expiration
    !object.no_expiration
  end

  def expiration_time
    object.expired_at
  end

  def conversion_type
    object.affiliate_conv_type
  end

  def disclaimer
    object.t_approval_message
  end

  def default_tracking_url
    object.active? ? affiliate_offer&.to_tracking_url : nil
  end

  def commission_range
    commissions = object.commission_details(affiliate: current_user, currency_code: currency_code)

    to_commission_range(commissions)
  end

  def deeplink
    object.default_offer_variant.can_config_url
  end

  def cap_size
    object.offer_cap.cap_size
  end

  def affiliate_offer
    instance_options[:affiliate_offers][object.id]
  end

  def conversion_time(value, num)
    return unless value

    t('conversion_time_info', value, n: num)
  end

  def t(key, value, **args)
    I18n.t("predefined.models.offer.#{key}.#{value}", **args)
  end
end
