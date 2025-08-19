class Teams::StepPriceSerializer < Base::StepPriceSerializer
  attributes :id, :conversion_step_id, :affiliate_offer_id

  conditional_attributes :custom_amount, :custom_share, :payout_amount, :payout_share,
    :is_true_share?, :is_affiliate_share?, if: -> { full_scope? || for_pay_schedule? }

  original_attributes :payout_amount, :custom_amount

  has_one :available_pay_schedule, if: :full_scope?

  def full_scope?
    super || context_class == Teams::AffiliateOfferSerializer
  end

  def for_pay_schedule?
    context_class == Teams::PayScheduleSerializer
  end
end
