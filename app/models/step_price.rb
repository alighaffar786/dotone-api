class StepPrice < DatabaseRecords::PrimaryRecord
  include Forexable
  include Traceable
  include Relations::HasPaySchedules

  belongs_to :affiliate_offer, inverse_of: :step_prices, touch: true
  belongs_to :conversion_step, inverse_of: :step_prices, touch: true

  has_one :true_currency, through: :conversion_step

  validates :conversion_step, presence: true
  validates :affiliate_offer_id, uniqueness: { scope: :conversion_step_id }
  # validates_with StepPriceHelpers::Validator::CustomPayValidator

  after_update :log_changes_for_network

  set_forexable_attributes :payout_amount, :custom_amount
  trace_has_many_includes :pay_schedules

  scope :with_true_pay, -> {
    joins(:conversion_step)
      .where(
        <<-SQL.squish
          conversion_steps.true_conv_type = 'CPS' AND payout_share > 0 OR
          conversion_steps.true_conv_type != 'CPS' AND payout_amount > 0
        SQL
      )
  }

  scope :with_affiliate_pay, -> {
    joins(:conversion_step)
      .where(
        <<-SQL.squish
          conversion_steps.affiliate_conv_type = 'CPS' AND custom_share > 0 OR
          conversion_steps.affiliate_conv_type != 'CPS' AND custom_amount > 0
        SQL
      )
  }

  delegate :is_true_share?, :is_affiliate_share?, to: :conversion_step

  # Returns true if share is blank for CPS or commission is blank for CPL
  def base_commission?
    (is_affiliate_share? && custom_share.blank?) ||
      (!is_affiliate_share? && custom_amount.blank?)
  end

  def original_currency
    true_currency&.code
  end

  def original_symbol
    true_currency&.symbol
  end

  def current_affiliate_share
    @current_affiliate_share ||= active_pay_schedule&.affiliate_share || custom_share
  end

  def current_affiliate_pay
    @current_affiliate_pay ||= active_pay_schedule&.forex_affiliate_pay || forex_custom_amount
  end

  def is_default?
    affiliate_offer&.default_step_price&.id == id
  end

  def should_ignore?(snapshot = nil)
    if is_true_share? && is_affiliate_share?
      return custom_share.to_f != 0 && (
        snapshot&.dig(:true_share).to_f != 0 && custom_share.to_f > snapshot[:true_share].to_f ||
        payout_share.to_f != 0 && custom_share.to_f > payout_share.to_f ||
        payout_share.to_f == 0 && conversion_step.true_share.to_f != 0 && custom_share.to_f > conversion_step.true_share.to_f
      )
    elsif !is_true_share? && !is_affiliate_share?
      return custom_amount.to_f != 0 && (
        snapshot&.dig(:true_pay).to_f != 0 && custom_amount.to_f > snapshot[:true_pay].to_f ||
        payout_amount.to_f != 0 && custom_amount.to_f > payout_amount.to_f ||
        payout_amount.to_f == 0 && conversion_step.true_pay.to_f != 0 && custom_amount.to_f > conversion_step.true_pay.to_f
      )
    end

    return false
  end

  def payout_details(currency_code = Currency.platform_code)
    schedule = active_pay_schedule

    if is_true_share?
      if schedule&.true_share.to_f > 0
        {
          type: 'limited',
          conv_type: conversion_step.true_conv_type,
          original_value: conversion_step.true_share,
          value: schedule.true_share,
          starts_at: schedule.starts_at,
          ends_at: schedule.ends_at,
        }
      elsif payout_share.to_f > 0
        {
          type: 'custom',
          conv_type: conversion_step.true_conv_type,
          original_value: conversion_step.true_share,
          value: payout_share,
        }
      end
    elsif schedule&.forex_true_pay.to_f > 0
      {
        type: 'limited',
        conv_type: conversion_step.true_conv_type,
        original_value: conversion_step.forex_true_pay(currency_code),
        value: schedule.forex_true_pay(currency_code),
        starts_at: schedule.starts_at,
        ends_at: schedule.ends_at,
      }
    elsif forex_payout_amount.to_f > 0
      {
        type: 'custom',
        conv_type: conversion_step.true_conv_type,
        original_value: conversion_step.forex_true_pay(currency_code),
        value: forex_payout_amount(currency_code),
      }
    end
  end

  def commission_details(currency_code = Currency.platform_code)
    schedule = active_pay_schedule

    if is_affiliate_share?
      if schedule&.affiliate_share.to_f > 0
        {
          type: 'limited',
          conv_type: ConversionStep::CONV_TYPE_CPS,
          original_value: conversion_step.affiliate_share,
          value: schedule.affiliate_share,
          date: schedule.ends_at,
        }
      elsif custom_share.to_f > 0
        {
          type: 'custom',
          conv_type: ConversionStep::CONV_TYPE_CPS,
          original_value: conversion_step.affiliate_share,
          value: custom_share,
        }
      end
    elsif conversion_step.is_flat_rate?(:affiliate)
      if schedule&.forex_affiliate_pay.to_f > 0
        {
          type: 'limited',
          conv_type: ConversionStep::CONV_TYPE_CPL,
          original_value: conversion_step.forex_affiliate_pay(currency_code),
          value: schedule.forex_affiliate_pay(currency_code),
          date: schedule.ends_at,
        }
      elsif forex_custom_amount.to_f > 0
        {
          type: 'custom',
          conv_type: ConversionStep::CONV_TYPE_CPL,
          original_value: conversion_step.forex_affiliate_pay(currency_code),
          value: forex_custom_amount(currency_code),
        }
      end
    end
  end

  private

  def log_changes_for_network
    return unless is_default?

    if is_true_share?
      if payout_changes = saved_changes[:payout_share]
        affiliate_offer.affiliate_logs.create(
          agent_type: 'Network',
          notes: "Custom commission changed from #{payout_changes[0].to_f}% to #{payout_changes[1].to_f}%",
        )
      end
    elsif payout_changes = saved_changes[:payout_amount]
      affiliate_offer.affiliate_logs.create(
        agent_type: 'Network',
        notes: "Custom commission changed from #{original_symbol}#{payout_changes[0].to_f} to #{original_symbol}#{payout_changes[1].to_f}",
      )
    end
  end
end
