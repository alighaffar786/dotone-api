class ConversionStep < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Forexable
  include FlexibleTranslatable
  include ModelCacheable
  include Traceable
  include Relations::HasPaySchedules
  include Relations::OfferAssociated

  CONV_TYPE_CPS = 'CPS'
  CONV_TYPE_CPL = 'CPL'
  CONV_TYPE_CPI = 'CPI'
  CONV_TYPE_CPA = 'CPA'
  CONV_TYPE_CPE = 'CPE'

  CONV_TYPES = [
    CONV_TYPE_CPS,
    CONV_TYPE_CPL,
    CONV_TYPE_CPI,
    CONV_TYPE_CPA,
    CONV_TYPE_CPE,
  ]

  CONVERSION_MODES = ['Auto', 'Manual']

  DEFAULT_NAME = 'default'
  DEFAULT_LABEL = 'Default'

  # In sort order
  ON_PAST_DUES = ['Do Nothing', 'Auto Approve', 'Auto Reject']

  attr_accessor :reset_commissions

  belongs_to_offer touch: true
  belongs_to :true_currency, class_name: 'Currency', inverse_of: :conversion_steps

  has_many :step_prices, inverse_of: :conversion_step, dependent: :destroy
  has_many :pay_schedules, -> { order_by_recent }, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :available_pay_schedules, -> { available }, as: :owner, inverse_of: :owner, class_name: 'PaySchedule'
  has_many :step_pixels, inverse_of: :conversion_step, dependent: :destroy

  validates :offer, presence: true
  validates :name, :label, presence: true, uniqueness: { scope: :offer_id }
  validates :conversion_mode, inclusion: { in: CONVERSION_MODES }
  validates :on_past_due, inclusion: { in: ON_PAST_DUES }
  validates :affiliate_conv_type, :true_conv_type, inclusion: { in: CONV_TYPES }

  before_validation :set_defaults
  after_save :reset_commissions_when_set

  define_constant_methods CONVERSION_MODES, :conversion_mode, prefix_instance: :conversion
  define_constant_methods ON_PAST_DUES, :on_past_due
  set_forexable_attributes :affiliate_pay, :true_pay, :max_affiliate_pay
  set_flexible_translatable_attributes(label: :plain)
  trace_has_many_includes :step_prices

  scope :ordered, -> {
    order(Arel.sql("CASE conversion_steps.name WHEN '#{ConversionStep::DEFAULT_NAME}' THEN -1 ELSE 0 END"))
      .order(created_at: :asc)
  }

  def self.conv_types(options = {})
    types = [CONV_TYPE_CPL, CONV_TYPE_CPS, CONV_TYPE_CPI, CONV_TYPE_CPE]
    types << CONV_TYPE_CPA if options[:cpa] == true
    types
  end

  def self.is_flat_rate?(type, value)
    return false if [:affiliate, :true].exclude?(type)

    [CONV_TYPE_CPL, CONV_TYPE_CPI, CONV_TYPE_CPE].include?(value)
  end

  def self.is_share_rate?(type, value)
    return false if [:affiliate, :true].exclude?(type)

    [CONV_TYPE_CPS].include?(value)
  end

  def on_past_due
    self[:on_past_due].presence || ConversionStep.on_past_due_do_nothing
  end

  def assign_forex_true_pay_changed?
    changed.include?('assign_forex_true_pay')
  end

  def is_default?
    offer.default_conversion_step&.id == id
  end

  def is_flat_rate?(type)
    value = if type == :affiliate
      affiliate_conv_type
    elsif type == :true
      true_conv_type
    end

    ConversionStep.is_flat_rate?(type, value)
  end

  def is_share_rate?(type)
    value = if type == :affiliate
      affiliate_conv_type
    elsif type == :true
      true_conv_type
    end

    ConversionStep.is_share_rate?(type, value)
  end

  def is_true_share?
    is_share_rate?(:true)
  end

  def is_affiliate_share?
    is_share_rate?(:affiliate)
  end

  def is_mixed_rate?(type)
    (is_flat_rate?(type) && is_share_rate?(type))
  end

  ##
  # Method to indicate that the conversion step is using
  # foreign currency payout.
  def foreign_currency?
    currency_rate_for_calculation > 1.0
  end

  def t_label_safe
    t_label || name
  end

  def name_to_trace
    "(CONVERSION STEP: #{name}) of (OFFER: #{offer&.id_with_name})"
  end

  def original_currency
    true_currency&.code
  end

  def assign_forex_true_pay
    @assign_forex_true_pay ||= nil
  end

  # Method to identify the default order status when nothing is specified.
  # Return based on its conversion mode.
  def default_order_status(options = {})
    return options[:approval] if options[:skip_mca_check] == true && options[:approval].present?
    conversion_manual? ? Order.status_pending : Order.status_confirmed
  end

  def commission_for_affiliate_offer(affiliate_offer)
    return if affiliate_offer.blank? || affiliate_offer.new_record?

    step_price = step_prices.find { |sp| sp.affiliate_offer_id == affiliate_offer.id }
    schedule = step_price&.active_pay_schedule

    flat_commission = step_price.present? ? step_price.forex_custom_amount : forex_affiliate_pay
    share_commission = step_price.present? ? step_price.custom_share : affiliate_share

    flat_commission = schedule && schedule.forex_affiliate_pay.to_f > 0 ? schedule.forex_affiliate_pay.to_f : flat_commission
    share_commission = schedule && schedule.affiliate_share.to_f > 0 ? schedule.affiliate_share.to_f : share_commission

    is_flat_rate?(:affiliate) ? [flat_commission, :flat] : [share_commission, :share]
  end

  ##
  # Obtain all conversion steps that belongs to the same offer
  def siblings
    return [] unless offer

    @siblings ||= offer.conversion_steps.where.not(id: id).to_a
  end

  def commission_currency
    offer.currency_for(:commission)
  end

  ##
  # Returns currency exchange rate
  # for this conversion point based on its
  # true currency. The optional custom_rates
  # can be supplied to avoid using real time
  # rates, which is useful to use rates
  # from the past
  def currency_rate(source_currency_code, target_currency_code, custom_rates = {})
    Currency.rate(
      source_currency_code,
      target_currency_code,
      custom_rates,
    )
  rescue Exception => e
    1.0
  end

  def currency_rate_for_calculation(custom_rates = {})
    currency_rate(
      true_currency&.code || Currency.platform_code,
      Currency.platform_code,
      custom_rates,
    )
  end

  def true_currency_id=(value)
    result = super(value)

    pay_schedules.each do |pay_schedule|
      pay_schedule.original_currency = original_currency
    end

    result
  end

  def current_affiliate_share
    @current_affiliate_share ||= (active_pay_schedule&.affiliate_share || affiliate_share)
  end

  def current_affiliate_pay
    @current_affiliate_pay ||= (active_pay_schedule&.forex_affiliate_pay || forex_affiliate_pay)
  end

  def current_true_share
    @current_true_share ||= (active_pay_schedule&.true_share || true_share)
  end

  def current_true_pay
    @current_true_pay ||= (active_pay_schedule&.forex_true_pay || forex_true_pay)
  end

  def payout_details(currency_code = Currency.platform_code)
    schedule = active_pay_schedule

    if is_share_rate?(:true)
      if schedule&.true_share.to_f > 0
        {
          type: 'limited',
          conv_type: true_conv_type,
          original_value: true_share,
          value: schedule.true_share,
          label: t_label_safe,
          starts_at: schedule.starts_at,
          ends_at: schedule.ends_at,
        }
      else
        {
          type: 'default',
          conv_type: true_conv_type,
          value: true_share,
          label: t_label_safe,
        }
      end
    elsif schedule&.forex_true_pay.to_f > 0
      {
        type: 'limited',
        conv_type: true_conv_type,
        original_value: forex_true_pay(currency_code),
        value: schedule.forex_true_pay(currency_code),
        label: t_label_safe,
        starts_at: schedule.starts_at,
        ends_at: schedule.ends_at,
      }
    else
      {
        type: 'default',
        conv_type: true_conv_type,
        value: forex_true_pay(currency_code),
        label: t_label_safe,
      }
    end
  end

  def commission_details(currency_code = Currency.platform_code)
    schedule = active_pay_schedule

    if is_share_rate?(:affiliate)
      if schedule&.affiliate_share.to_f > 0
        {
          type: 'limited',
          conv_type: CONV_TYPE_CPS,
          original_value: affiliate_share,
          value: schedule.affiliate_share,
          start_at: schedule.starts_at,
          date: schedule.ends_at,
        }
      elsif affiliate_share.to_f > 0
        {
          type: 'default',
          conv_type: CONV_TYPE_CPS,
          value: affiliate_share,
        }
      end
    elsif is_flat_rate?(:affiliate)
      if schedule&.forex_affiliate_pay.to_f > 0
        {
          type: 'limited',
          conv_type: CONV_TYPE_CPL,
          original_value: forex_affiliate_pay(currency_code),
          value: schedule.forex_affiliate_pay(currency_code),
          start_at: schedule.starts_at,
          date: schedule.ends_at,
        }
      elsif forex_affiliate_pay.to_f > 0
        {
          type: 'default',
          conv_type: CONV_TYPE_CPL,
          value: forex_affiliate_pay(currency_code),
        }
      end
    end
  end

  def destroy
    siblings.size > 0 && super
  end

  private

  def set_defaults
    self.session_option = false if session_option.nil?
    self.true_currency_id ||= Currency.platform.id
    self.days_to_expire = 0 if session_option?
    self.days_to_expire = 90 if days_to_expire.blank?
    self.days_to_return = 90 if days_to_return.blank?
    self.conversion_mode ||= ConversionStep.conversion_mode_auto
    self.on_past_due ||= ConversionStep.on_past_due_do_nothing
    self.name ||= DEFAULT_NAME
    self.label ||= DEFAULT_LABEL
    self.affiliate_pay = 0 if affiliate_pay_flexible?
    self.max_affiliate_pay = 0 if affiliate_pay_flexible?
  end

  def reset_commissions_when_set
    return unless BooleanHelper.truthy?(reset_commissions)

    custom_amount = is_flat_rate?(:affiliate) ? affiliate_pay : nil
    custom_share = is_share_rate?(:affiliate) ? affiliate_share : nil

    step_prices.each do |step_price|
      step_price.custom_amount = custom_amount
      step_price.custom_share = custom_share
    end
  end
end
