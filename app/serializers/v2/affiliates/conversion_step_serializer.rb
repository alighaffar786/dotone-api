class V2::Affiliates::ConversionStepSerializer < Base::ConversionStepSerializer
  include DotOne::Api::V2Helper

  attributes :name, :conversion_type, :conversion_mode, :referral_sessions, :referral_day_period,
    :commission_currency, :label, :commission, :scheduled

  def commission
    value, conv_type = object.commission_for_affiliate_offer(affiliate_offer)

    if conv_type == :flat
      to_currency(value)
    elsif conv_type == :share
      to_percentage(value)
    end
  end

  def scheduled
    commission = object.commission_details(currency_code: currency_code)

    return unless commission && commission[:date]

    value = if ConversionStep.is_share_rate?(:affiliate, commission[:conv_type])
      to_percentage(commission[:value])
    elsif ConversionStep.is_flat_rate?(:affiliate, commission[:conv_type])
      to_currency(commission[:value])
    end

    {
      commission: value,
      start_at: commission[:start_at].to_date,
      end_at: commission[:date].to_date,
    }
  end

  def conversion_type
    object.affiliate_conv_type
  end

  def referral_sessions
    object.session_option
  end

  def referral_day_period
    object.session_option ? nil : object.days_to_expire
  end

  def commission_currency
    object.commission_currency&.code
  end

  def affiliate_offer
    instance_options[:affiliate_offers][object.offer_id]
  end
end
