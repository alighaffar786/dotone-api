class PaySchedule < DatabaseRecords::PrimaryRecord
  include DateRangeable
  include Forexable
  include LocalTimeZone
  include Owned
  include Traceable

  attr_writer :original_currency

  validates :starts_at_local, :ends_at_local, presence: true
  validates_with PayScheduleHelpers::Validator::PayValidator
  validates_with PayScheduleHelpers::Validator::DateValidator, if: :new_record?

  before_save :set_expired_at

  set_local_time_attributes :starts_at, :ends_at, :created_at, :updated_at, :expired_at
  set_forexable_attributes :true_pay, :affiliate_pay

  scope :order_by_recent, -> { order(starts_at: :desc) }
  scope :order_by_updated, -> { order(updated_at: :desc) }
  scope :expired, -> { where('expired IS TRUE OR ends_at < NOW()') }
  scope :active, -> {
    where('expired IS NOT TRUE AND starts_at <= NOW() AND ends_at >= NOW()').order(starts_at: :asc)
  }

  scope :available, -> {
    where('expired is NOT TRUE AND (starts_at <= NOW() AND ends_at >= NOW() OR ends_at >= NOW())').order(starts_at: :asc)
  }

  scope :joins_conversion_step, -> {
    joins(
      <<-SQL.squish
        LEFT JOIN conversion_steps
          ON CASE
            WHEN owner_type = 'ConversionStep' THEN conversion_steps.id = owner_id
            WHEN owner_type = 'StepPrice' THEN conversion_steps.id in (SELECT step_prices.conversion_step_id FROM step_prices where step_prices.id = owner_id)
          END
      SQL
    )
  }

  scope :with_true_pay, -> {
    joins_conversion_step
      .where(
        <<-SQL.squish
          conversion_steps.true_conv_type = 'CPS' AND pay_schedules.true_share > 0 OR
          conversion_steps.true_conv_type != 'CPS' AND pay_schedules.true_pay > 0
        SQL
      )
  }

  scope :with_affiliate_pay, -> {
    joins_conversion_step
      .where(
        <<-SQL.squish
          conversion_steps.affiliate_conv_type = 'CPS' AND pay_schedules.affiliate_share > 0 OR
          conversion_steps.affiliate_conv_type != 'CPS' AND pay_schedules.affiliate_pay > 0
        SQL
      )
  }

  delegate :true_conv_type, :affiliate_conv_type, to: :conversion_step, allow_nil: true

  def original_currency
    @original_currency ||= owner.try(:original_currency)
  end

  def conversion_step
    if owner.is_a?(ConversionStep)
      owner
    elsif owner.respond_to?(:conversion_step)
      owner.conversion_step
    end
  end

  def expired
    super || (ends_at.to_date < Time.now.utc.to_date)
  end

  def ends_at_local=(*args)
    value, timezone_or_id = args.flatten

    timezone = if timezone_or_id.is_a?(Integer)
      TimeZone.cached_find(timezone_or_id)
    else
      timezone_or_id
    end

    if value.present?
      time = DateTime.parse(value.to_s).end_of_day
      self.ends_at = timezone.to_utc(time)
    else
      self.ends_at = nil
    end
  end

  def expired?
    expired
  end

  def active?
    today = Time.now.utc.to_date
    !expired && starts_at.to_date <= today && ends_at.to_date >= today
  end

  def pending?
    today = Time.now.utc.to_date
    !expired && starts_at.to_date > today
  end

  def valid_payout?
    return false unless conversion_step

    if conversion_step.is_share_rate?(:true)
      true_share.present?
    else
      true_pay.present?
    end
  end

  def valid_commission?
    return false unless conversion_step

    if conversion_step.is_share_rate?(:affiliate)
      affiliate_share.present?
    else
      affiliate_pay.present?
    end
  end

  def expired_at
    super || updated_at
  end

  private

  def set_expired_at
    return unless expired? && expired_changed? && expired_at.blank?

    self.expired_at = Time.now.utc
  end
end
