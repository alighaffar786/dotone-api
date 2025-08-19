module AffiliateStatHelpers::ConversionProcess
  extend ActiveSupport::Concern
  include AffiliateStatHelpers::ConversionHelper
  include AffiliateStatHelpers::PayoutCommissionCalculator

  module ClassMethods
    def process_conversion_args(*args)
      if args.length == 2
        conversion_options = args[0]
        options = args[1] || {}
      else
        options = args[0] || {}
        conversion_options = DotOne::Utils::ConversionOptions.new(options.with_indifferent_access)
      end

      conversion_options = DotOne::Utils::ConversionOptions.new(conversion_options || {}) unless conversion_options.is_a?(DotOne::Utils::ConversionOptions)

      [conversion_options, options.with_indifferent_access]
    end
  end

  # This is a method to process conversion of this stat.
  # The processes include:
  # => calculate payouts and commissions
  # => convert the transaction
  # => set approval and status
  # => fire any S2S pixels
  # It returns what pixels (HTML, S2S) that are
  # included for postbacks as well as any error
  # generated from the process
  #
  # Available options:
  #
  #   - order_number: any order number attached to this conversion
  #
  #   - order: alias for order_number. Both represents the same thing
  #
  #   - order_total: the dollar value for this order. It is rather
  #       the total value of the order instead of the commission
  #
  #   - revenue: the payout for this transaction. If supplied,
  #       this will become the payout for this transaction
  #       regardless of the order_total % or recorded payout
  #       on the system
  #
  #   - approval: the new approval status this transaction
  #       is assigned to
  #
  #   - captured_at: the new captured time that this transaction
  #       is assigned to
  #
  #   - converted_at: the new conversion time that this transaction
  #       is assigned to
  #
  #   - step: the step_name this transaction belongs to. It tells
  #       the processor which conversion point to use in order
  #       to calculate the payouts, commissions, and other information
  #
  #   - trace_custom_agent: the string representing the
  #       agent that does the processing. This string will
  #       be logged to the trace attached to this transaction.
  #       This is useful to indicate where the transaction is processed
  #       from, whether scheduled processor, API, or UI
  #
  #   - skip_expiration_check: if true, any transaction/order
  #       beyond its expiration period will be processed.
  #       Otherwise, it will be skipped
  #
  #   - skip_revert_no_campaign: the flag when set to true
  #       will set conversion to invalid due to non-existed
  #       active campaign
  #
  #   - skip_offer_status: if set to true, conversion will
  #       not subject to offer status. Otherwise, when offer
  #       is not active, any conversion will not be set
  #       to approved
  #
  #   - skip_mca_check: if set to true, regardless of offer
  #       is manual or auto approved, it will be set to the
  #       given approval status. Otherwise, it will be set
  #       to pending
  #
  #   - skip_currency_adjustment: if set to true, payout or
  #       commission will be assumed to have local
  #       currency
  #
  #   - real_time: the flag to tell the processor that
  #       this conversion occurs in real time, for example
  #       thru pixel postback
  #
  #   - no_modification_on_final_status: the flag to tell
  #       processor that if this transaction is on final
  #       status, don't do anything else
  #
  #   - reload_transaction: before transaction is being processed
  #       make sure to reload it first to get the most up-to-date
  #       value. This is useful for delayed process
  def process_conversion!(*args)
    conversion_options, options = self.class.process_conversion_args(*args)

    arg_string = "stat_id = #{id} options = #{options}"
    log_prefix = '[ConversionProcess#process_conversion]'

    options = options.with_indifferent_access

    self.reload if options[:reload_transaction] == true

    setup = {
      html_pixels: [],
      s2s_pixels: [],
      convert: false,
      errors: [],
      order: nil,
    }
    return setup unless proceed_with_conversion?(options)

    logger.warn "#{log_prefix} Proceeed with conversion: #{arg_string}"

    result = {}

    begin
      result = process(conversion_options, options)
    rescue DotOne::Errors::BaseError => e
      setup[:errors] << e.full_message
    end

    if result[:status] == 'success'
      adjusted_stat = result[:adjusted_stat]
      setup[:order] = result[:order]
      setup[:convert] = true
      setup[:s2s_pixels] = adjusted_stat.s2s_pixels

      logger.warn "#{log_prefix} Stat is Converted: #{arg_string}"

      adjusted_stat.pending_with_conversion? && adjusted_stat.mca?
      additional_info = [
        "pending_with_conversion: #{adjusted_stat.pending_with_conversion?}",
        "mca: #{adjusted_stat.mca?}",
      ]
      logger.warn "#{log_prefix} Stat is Pending & MCA: #{arg_string} #{additional_info.join(' ')}"
    else
      setup[:convert] = false
    end

    setup
  end

  # options: {
  #   :step => [the current step to process],
  #   :skip_expiration_check => [true or false],
  #   :skip_duplicate_ip_check => [true or false],
  #   :skip_proximity_order => [true or false],
  #   :skip_currency_adjustment => [true or false],
  #   :skip_approved_transaction => [true or false],
  #   :order_total =>  total amount of the order,
  #   :revenue => commission amount from the order total,
  #   :approval => order status,
  #   :order => order number,
  #   :real_time => indicate that incoming conversion
  #     is from real time sources
  #   :no_modification_on_final_status => when true,
  #     it will not update anything when transaction
  #     is on final status. It will return error
  #   :user_role => The current user (if any) that
  #     operates this process this under
  # }

  def process(*args)
    conversion_options, options = self.class.process_conversion_args(*args)

    puts "OPTIONS: #{options}"

    result = {}

    # Handle campaign level conversion process
    return process_for_campaign(options) if offer_id.blank? && campaign_id.present?

    # Sanitize dollar values
    options[:revenue] = sanitize_currency_amount(options[:revenue])
    options[:order_total] = sanitize_currency_amount(options[:order_total])
    options[:true_pay] = sanitize_currency_amount(options[:true_pay])
    options[:captured_at] ||= format_time_values(options[:captured_at_local])
    options[:published_at] ||= format_time_values(options[:published_at_local])
    options[:converted_at] ||= format_time_values(options[:converted_at_local])

    if options[:user_role] == :owner
      options[:affiliate_pay] = sanitize_currency_amount(options[:affiliate_pay])
    else
      options[:affiliate_pay] = nil
      options[:affiliate_share] = nil
    end

    if current_offer = cached_offer || cached_offer_variant&.cached_offer
      self.offer = current_offer
      self.offer_id = current_offer.id
    end

    # Handle step name specification
    current_step_name = options[:step].presence || options[:step_name].presence || step_name
    current_step_name ||= current_offer&.cached_default_conversion_step&.name

    puts "[#{self.class}##{__method__}] CURRENT STEP NAME: #{current_step_name}"

    conv_step = conversion_step(current_step_name)

    # order number
    current_order_number = (options[:order].presence || options[:order_number].presence || order_number).to_s.presence

    # order total
    current_order_total = options[:order_total].presence || order_total

    # revenue
    # True pay is an option to consider since we treat
    # revenue the same as true pay. So, if true_pay
    # is given without any revenue defined, we will
    # take it as consideration.
    current_true_pay = options[:revenue].presence || options[:true_pay].presence
    current_true_pay ||= true_pay if options[:order_total].blank?

    adjusted_stat = self

    # Find order
    # Retrieve any converted order - if any
    converted_order = AffiliateStat.find_order(adjusted_stat, order_number: current_order_number, conversion_step: conv_step)
    # Get the real stat from order
    adjusted_stat = converted_order.copy_stat if converted_order.present?

    result[:adjusted_stat] = adjusted_stat
    result[:id] = adjusted_stat.id

    AffiliateStat.raise_error_when_approval_change_invalid(adjusted_stat, conversion_options, options)

    updating_existing_order = converted_order.present? || adjusted_stat.conversions?

    if updating_existing_order
      if converted_order.present?
        current_step_name = converted_order.step_name || current_step_name
      else
        current_step_name = adjusted_stat.step_name || current_step_name
      end

      conv_step = conversion_step(current_step_name)
    end

    calculator_options = options.except(:skip_calculation)
    calculator_options = calculator_options.merge!(skip_calculation: updating_existing_order, adjusted_stat: adjusted_stat) if options[:skip_calculation] == true

    # Calculate the payout and commission

    puts "CALCULATE PARAMETERS: order_total = #{current_order_total}. true_pay = #{current_true_pay}. current_step_name = #{current_step_name}. options = #{options}"

    _, _, order_total_to_record, payout, commission, payout_share, commission_share, conv_step_snapshot, margin, forex_rate = calculate_payout_and_commission(
      current_order_total, current_true_pay, current_step_name, calculator_options
    )

    current_true_conv_type = conv_step_snapshot&.dig(:true_conv_type) || conv_step.true_conv_type
    current_affiliate_conv_type = conv_step_snapshot&.dig(:affiliate_conv_type) || conv_step.affiliate_conv_type

    if options[:real_time] != true && updating_existing_order
      options.merge!(
        skip_mca_check: true,
        skip_offer_status: true,
        skip_order_status_check: true,
        skip_revert_no_campaign: true,
        skip_affiliate_status: true,
      )
    end

    # Decide order status
    order_status = conv_step.default_order_status(options)

    skip_revert_no_campaign = options[:skip_revert_no_campaign] == true
    reject_on_negative_margin = options[:on_negative_margin]&.to_sym == :reject
    skip_offer_status = options[:skip_offer_status] == true
    skip_affiliate_status = options[:skip_affiliate_status] == true

    set_published_instead = set_to_published_instead?(conversion_options, options.merge(conversion_step: conv_step))

    puts "SET TO PUBLISHED INSTEAD: #{set_published_instead}"

    # Automatically set to Rejected if campaign is paused and it is real time
    order_status = Order.status_published if set_published_instead
    order_status = Order.status_rejected if auto_set_to_rejected?(options)
    order_status = Order.status_invalid if !skip_offer_status && !adjusted_stat.offer_variant_active_or_test?
    order_status = Order.status_invalid if !skip_affiliate_status && adjusted_stat.affiliate&.suspended?
    order_status = Order.status_no_active_campaign if !skip_revert_no_campaign && !adjusted_stat.affiliate_offer&.considered_approved?
    order_status = Order.status_negative_margin if reject_on_negative_margin && margin < 0.0
    order_status ||= converted_order&.status || adjusted_stat.status

    check_result = AffiliateStat.check_on_order_status(adjusted_stat, options.merge(conversion_step: conv_step, order_status: order_status))
    order_status = check_result[:order_status]

    # Set captured_at
    order_recorded_at = converted_order&.recorded_at || adjusted_stat.captured_at || options[:captured_at].presence
    order_recorded_at = options[:captured_at] if options[:captured_at].present? && options[:override_captured_at] == true
    order_published_at = options[:published_at].presence || converted_order&.published_at || adjusted_stat.published_at
    order_converted_at = options[:converted_at].presence || converted_order&.converted_at || adjusted_stat.converted_at
    order_recorded_at ||= order_published_at || order_converted_at || Time.now

    updates = {
      step_name: conv_step.name,
      step_label: conv_step.label,
      true_pay: payout,
      affiliate_pay: commission,
      trace_custom_agent: options[:trace_custom_agent],
      trace_agent_via: options[:trace_agent_via],
      true_conv_type: current_true_conv_type,
      affiliate_conv_type: current_affiliate_conv_type,
      status: order_status,
      published_at: order_published_at,
      converted_at: order_converted_at,
    }

    if current_offer&.multi_conversion_point? || adjusted_stat.original&.orders&.any?
      updates.merge!(
        recorded_at: order_recorded_at,
        true_share: payout_share,
        affiliate_share: commission_share,
        total: order_total_to_record,
      )

      if converted_order.present?
        puts "UPDATES: #{updates}"

        converted_order.update!(updates)

        puts "CONVERTED ORDER ERROR: #{converted_order.errors.messages}"

        result[:new_order] = false
      elsif adjusted_stat.original_id
        updates.merge!(
          order_number: current_order_number,
          network_id: adjusted_stat.network_id,
          offer_id: adjusted_stat.offer_id,
          offer_variant_id: adjusted_stat.offer_variant_id,
          affiliate_id: adjusted_stat.affiliate_id,
          affiliate_stat_id: adjusted_stat.original_id,
          forex: forex_rate,
        )

        converted_order = Order.create!(updates)

        result[:new_order] = true
      end

      result[:order] = converted_order

      if converted_order.blank?
        exception = Exception.new("Click Stat not found for #{id} - #{options}")
        Sentry.capture_exception(exception) if Rails.env.production?
        raise exception
      end

      adjusted_stat = converted_order.reload.copy_stat

      # Record advertiser uniq id
      adjusted_stat.update!(adv_uniq_id: options[:adv_uniq_id]) if options[:adv_uniq_id].present?
    else
      updates.merge!(
        conversions: 1,
        captured_at: order_recorded_at,
        order_total: order_total_to_record,
        order_number: current_order_number,
        forex: forex_rate,
      )

      updates.merge!(adv_uniq_id: options[:adv_uniq_id]) if options[:adv_uniq_id].present?

      DotOne::Utils::Rescuer.no_deadlock do
        adjusted_stat.update!(updates)
      end
    end

    adjusted_stat = adjusted_stat.reload

    result[:adjusted_stat] = adjusted_stat
    result[:id] = adjusted_stat.id
    result[:status] = 'success'

    result
  end

  def recalculate!(options = {}, calculator_options = {})
    return unless conversions?

    order_total_to_use = options.key?(:order_total) ? options[:order_total] : copy_order&.total || order_total
    true_pay_to_use = options.key?(:revenue) ? options[:revenue] : true_pay
    step_name_to_use = options[:step].presence || step_name

    conv_step, _, order_total_to_record, payout, commission, true_share, affiliate_share = calculate_payout_and_commission(
      order_total_to_use,
      true_pay_to_use,
      step_name_to_use,
      { skip_currency_adjustment: true }.merge(calculator_options)
    )

    return if calculator_options[:step_name_correction] && DotOne::Utils.str_match?(conv_step.name, step_name)

    update(
      order_total: order_total_to_record,
      true_pay: payout,
      affiliate_pay: commission,
      step_name: conv_step.name,
      step_label: conv_step.label
    )

    update_order!(true_share: true_share, affiliate_share: affiliate_share)
  end

  ##
  # Helper to indicate if stat supposed to be set
  # to published instead when approving a conversion
  def set_to_published_instead?(*args)
    conversion_options, options = self.class.process_conversion_args(*args)

    # From CSV upload when we want to bypass the published step
    return false if conversion_options.is_payment_received
    return false if conversion_options.skip_set_to_published

    # In real time conversion postback, approval is not truly
    # set and assumption is made that conversion is on Pending or Approved
    # depending on the offer approval mode

    mca = (options[:conversion_step] || conversion_step)&.conversion_manual?
    assumed_approval = options[:skip_mca_check] != true && mca ? AffiliateStat.approval_pending : AffiliateStat.approval_approved
    assumed_approval = AffiliateStat.approval_rejected if auto_set_to_rejected?(options)
    assumed_approval = options[:real_time] == true ? assumed_approval : options[:approval]

    AffiliateStat.approvals_positive.include?(assumed_approval) && set_to_published?
  end

  def set_to_published?
    cached_affiliate&.approval_method == Offer.approval_method_payment_received ||
    cached_offer&.approval_method == Offer.approval_method_payment_received
  end

  def auto_set_to_rejected?(options = {})
    options[:real_time] == true && options[:skip_revert_no_campaign] != true && !affiliate_offer&.considered_approved?
  end

  def process_for_campaign(options)
    result = {}
    update!(
      conversions: 1,
      approval: AffiliateStat.approval_approved,
      captured_at: Time.now,
      published_at: Time.now,
      converted_at: Time.now,
      adv_uniq_id: options[:adv_uniq_id],
    )
    result[:status] = 'success'
    result[:adjusted_stat] = self
    result[:id] = id
    result
  end

  private

  ##
  # This is a method to check if this stat needs to be processed for conversion.
  # That is, only process conversion when it is not converted yet or if there is
  # conversion point (step) to be processed.
  def proceed_with_conversion?(options = {})
    options[:step].present? ||
    !converted? ||
    considered_pending?(:network) ||
    options[:force] == true
  end

  def sanitize_currency_amount(value)
    value.is_a?(String) ? value.gsub(/,/, '') : value
  end

  def format_time_values(values)
    return unless values.is_a?(Array)

    value, time_zone_id = values

    TimeZone.cached_find(time_zone_id).to_utc(value)
  end
end
