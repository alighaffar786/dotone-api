class Teams::PayScheduleSerializer < ApplicationSerializer
  local_time_attributes(*PaySchedule.local_time_attributes)
  forexable_attributes(*PaySchedule.forexable_attributes)

  attributes :id, :owner_id, :owner_type, :starts_at, :ends_at, :true_pay, :true_share,
    :affiliate_pay, :affiliate_share, :active?, :valid_payout?, :valid_commission?, :original_true_pay, :original_affiliate_pay,
    :expired?, :created_at, :updated_at, :expired_at

  conditional_attributes :affiliate_offer_id, :conversion_step_id, if: :step_price_info?

  has_one :owner, if: :full_scope?
  has_one :original_currency

  def original_true_pay
    object.true_pay
  end

  def original_affiliate_pay
    object.affiliate_pay
  end

  def step_price_info?
    object.owner_type == 'StepPrice' && full_scope?
  end

  def affiliate_offer_id
    return unless object.owner_type == 'StepPrice'
    object.owner.affiliate_offer_id
  end

  def conversion_step_id
    return unless object.owner_type == 'StepPrice'
    object.owner.conversion_step_id
  end
end
