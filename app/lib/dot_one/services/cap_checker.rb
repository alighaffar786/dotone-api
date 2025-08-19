class DotOne::Services::CapChecker
  attr_accessor :options, :ratio

  def initialize(options)
    @options = options
    @ratio = 0.00
    @cap_instance = options[:cap_instance]
    @cap_size = @options[:cap_size]
    @upper_threshold = @options[:upper_threshold]
    @lower_threshold = @options[:lower_threshold]

    return unless @cap_size.present?

    # We do not want to use round(2) here because
    # it will round to nearest decimal which if 0.946 will
    # round to 0.95 - which is wrong.
    # So, what we should do is to just remove any extra
    # decimal point.
    # For example:
    # 0.946343 will become 0.94 (instead of 0.95)
    conversion_so_far = @cap_instance.respond_to?(:conversion_so_far) && @cap_instance.conversion_so_far.to_f
    conversion_so_far = 0 if conversion_so_far.blank?

    @ratio = if @cap_size == 0
      1.00
    else
      ((conversion_so_far / @cap_size.to_f) * 100).floor / 100.0
    end
  end

  def when_depleting
    Rails.logger.warn "[#{Time.now}][CAP CHECKER#when_depleting] Cap ID: #{@cap_instance.id} Offer ID: #{@cap_instance.try(:offer_variant).try(:offer_id)} Ratio is depleting: #{ratio_is_depleting?} Has been notified: #{has_been_notified?}"
    return unless ratio_is_depleting? && !has_been_notified?

    yield(@cap_instance)
    @cap_instance.update(cap_notified_at: @ratio)
  end

  def when_depleted
    Rails.logger.warn "[#{Time.now}][CAP CHECKER#when_depleted] Cap ID: #{@cap_instance.id} Offer ID: #{@cap_instance.try(:offer_variant).try(:offer_id)} Notified Ratio: #{notified_ratio} Ratio: #{@ratio}"
    return unless notified_ratio < 1.0 && @ratio >= 1.0

    yield(@cap_instance)
    @cap_instance.update(cap_notified_at: @ratio)
  end

  def when_reset
    return unless @ratio < notified_ratio

    yield(@cap_instance)
  end

  def check
    yield(self)
  end

  def notified_ratio
    @options[:cap_notified_at].to_f
  end

  def closest_threshold_from_ratio
    if @ratio >= @upper_threshold
      @upper_threshold
    elsif @ratio >= @lower_threshold
      @lower_threshold
    end
  end

  private

  def ratio_is_depleting?
    @ratio >= @lower_threshold && @ratio < 1.0
  end

  def has_been_notified?
    return false if notified_ratio <= 0.00

    @ratio >= notified_ratio && (
      (closest_threshold_from_ratio == @lower_threshold && notified_ratio >= @lower_threshold && notified_ratio < @upper_threshold) ||
      (closest_threshold_from_ratio == @upper_threshold && notified_ratio >= @upper_threshold)
    )
  end
end
