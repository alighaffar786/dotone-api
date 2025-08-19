module HasCap
  extend ActiveSupport::Concern
  include ConstantProcessor

  CAP_TYPES = [
    'Monthly Cap',
    'Daily Cap',
    'Lifetime Cap',
  ]

  included do
    scope :cap_defined, -> { where(cap_type: CAP_TYPES).where.not(cap_size: [nil, 0]) }

    before_save :adjust_cap_values

    define_constant_methods CAP_TYPES, :cap_type

    alias_method :earliest_at_local, :cap_earliest_at_local
    alias_method :earliest_at_local=, :cap_earliest_at_local=
  end

  def cap_earliest_at_local(time_zone = nil)
    return if cap_earliest_at.blank?

    time_zone ||= cap_time_zone_item || TimeZone.current
    time_zone.from_utc(cap_earliest_at)
  end

  def cap_earliest_at_local=(*args)
    value = args[0]
    time_zone = cap_time_zone_item || TimeZone.current

    if value.present?
      time = DateTime.parse(value.to_s)
      self.cap_earliest_at = time_zone.to_utc(time)
    else
      self.cap_earliest_at = nil
    end
  end

  def reset_cap!
    raise NotImplementedError
  end

  # Method to run reset cap sometime in the future.
  # Remember, each cap has its own time zone.
  def schedule_reset_cap
    return if cap_time_zone_item.blank? || cap_type.blank?

    run_time =
      if monthly_cap?
        cap_time_zone_item.to_utc((cap_time_zone_item.from_utc(Time.now) + 1.month).beginning_of_month)
      elsif daily_cap?
        cap_time_zone_item.to_utc((cap_time_zone_item.from_utc(Time.now) + 1.day).beginning_of_day)
      end

    return unless run_time.present? && !reset_cap_scheduled?(run_time)

    OfferCaps::ResetJob.set(wait_until: run_time).perform_later(self.class.name, id, run_time.to_s)
  end

  private

  def reset_cap_scheduled?(run_time)
    DotOne::SidekiqHelper.scheduled?('OfferCaps::ResetJob', self.class.name, id, run_time.to_s)
  end

  def adjust_cap_values
    return unless cap_type.blank?

    self.cap_size = nil
    self.cap_earliest_at = nil
  end
end
