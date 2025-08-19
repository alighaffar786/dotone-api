class Teams::ConversionStepSerializer < Base::ConversionStepSerializer
  attributes :id, :offer_id, :true_currency_id

  conditional_attributes :name, :label, :currency_rate_for_calculation, :days_to_return, :days_to_expire, :conversion_mode,
    :session_option, :on_past_due, :is_default?, :original_true_pay, :original_affiliate_pay, :t_label_static?, if: :full_scope?

  conditional_attributes :true_conv_type, :affiliate_conv_type, :true_pay, :true_share,
    :affiliate_pay, :affiliate_share, :is_true_share?, :is_affiliate_share?, if: -> { full_scope? || for_affiliate_offer? }

  has_many :available_pay_schedules, if: :full_scope?
  has_many :label_translations, if: :full_scope?

  has_one :true_currency
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer, if: :full_scope?
  has_one :available_pay_schedule, if: -> { for_affiliate_offer? || full_scope? }

  def for_affiliate_offer?
    context_class == Teams::AffiliateOfferSerializer
  end
end
