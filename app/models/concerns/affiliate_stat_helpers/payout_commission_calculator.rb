module AffiliateStatHelpers::PayoutCommissionCalculator
  def calculate_payout_and_commission(order_total, revenue, step_name, options = {})
    puts "[CALCULATOR] Arguments: order_total: #{order_total}. revenue: #{revenue}. step_name: #{step_name}. options: #{options}"

    # Conversion step
    conv_step = conversion_step(step_name)

    if conv_step.blank?
      raise DotOne::Errors::InvalidDataError({
        order_total: order_total,
        revenue: revenue,
        step_name: step_name,
        options: options,
      }, 'data.unknown_conversion_step')
    end

    # Skip currency adjustment when specified
    skip_currency_adjustment = options[:skip_currency_adjustment] == true

    # Skip existing commission during calculation when specified
    skip_existing_commission = options[:skip_existing_commission] == true

    skip_existing_payout = options[:skip_existing_payout] == true

    supplied_affiliate_pay = options[:affiliate_pay].to_f
    supplied_true_pay = options[:true_pay].to_f
    supplied_revenue = revenue.to_f

    supplied_currency_code = options[:currency_code]

    multiplier = if Currency.currency_valid?(supplied_currency_code)
      Currency.rate(supplied_currency_code, Currency.platform_code, currency_rate_map)
    else
      conv_step.currency_rate_for_calculation(currency_rate_map) || 1.0
    end

    unless skip_currency_adjustment
      supplied_true_pay *= multiplier
      supplied_revenue *= multiplier
      supplied_affiliate_pay *= multiplier
    end

    # Get custom share & commission if any
    step_price = self.step_price(conv_step.name)

    snapshots = original.refresh_conversion_step_snapshot! unless snapshots = original.conversion_steps
    snapshot = snapshots.transform_keys { |name| name.downcase }.dig(conv_step.name.downcase)&.with_indifferent_access

    puts "[CALCULATOR] CONV STEP: #{print_attributes(conv_step.attributes)}"
    puts "[FOREX] #{currency_rate_map}"
    puts "[CALCULATOR] Multiplier: #{multiplier}"
    puts "[CALCULATOR] Step Price: #{print_attributes(step_price.attributes)}" if step_price
    puts "[CALCULATOR] snapshot: #{snapshot}"

    if snapshot.present?
      if snapshot[:currency_code].present?
        conversion_step_currency = supplied_currency_code || conv_step.original_currency
        snapshot_multiplier = Currency.rate(snapshot[:currency_code], conversion_step_currency, currency_rate_map)
        snapshot[:affiliate_pay] *= snapshot_multiplier if snapshot[:affiliate_pay]
        snapshot[:true_pay] *= snapshot_multiplier if snapshot[:true_pay]
        snapshot[:currency_code] = conversion_step_currency

      elsif (order_total.to_f > 0 || supplied_revenue > 0)
        snapshot = nil
      end
    end

    puts "[CALCULATOR] snapshot after adjustment: #{snapshot}"

    true_conv_type_to_use = snapshot&.dig(:true_conv_type) || conv_step.true_conv_type
    using_true_share = ConversionStep.is_share_rate?(:true, true_conv_type_to_use)
    using_true_flat_rate = ConversionStep.is_flat_rate?(:true, true_conv_type_to_use)

    affiliate_conv_type_to_use = snapshot&.dig(:affiliate_conv_type) || conv_step.affiliate_conv_type
    using_affiliate_share = ConversionStep.is_share_rate?(:affiliate, affiliate_conv_type_to_use)
    using_affiliate_flat_rate = ConversionStep.is_flat_rate?(:affiliate, affiliate_conv_type_to_use)

    snapshot = nil if using_true_share && using_affiliate_share && snapshot&.dig(:affiliate_share).to_f > snapshot&.dig(:true_share).to_f
    snapshot = nil if using_true_flat_rate && using_affiliate_flat_rate && snapshot&.dig(:affiliate_pay).to_f > snapshot&.dig(:true_pay).to_f

    step_price = nil if step_price&.should_ignore?(snapshot)

    if options[:skip_calculation] == true && adjusted_stat = options[:adjusted_stat]
      return [
        conv_step,
        step_price,
        adjusted_stat.order_total,
        adjusted_stat.true_pay,
        adjusted_stat.affiliate_pay,
        adjusted_stat.copy_order&.true_share,
        adjusted_stat.copy_order&.affiliate_share,
        snapshot,
        adjusted_stat.true_pay.to_f - adjusted_stat.affiliate_pay.to_f,
        adjusted_stat.forex,
      ]
    end

    true_share_from_record = 0
    true_pay_from_record = 0

    if using_true_share
      true_share_from_record = DotOne::Utils.return_meaningful_amount(
        options[:true_share],
        snapshot&.dig(:true_share),
        step_price&.payout_share,
        conv_step.true_share
      )
    else
      true_pay_from_record = DotOne::Utils.return_meaningful_amount(
        snapshot&.dig(:true_pay),
        step_price&.payout_amount,
        conv_step.true_pay
      )

      true_pay_from_record *= multiplier unless skip_currency_adjustment
    end

    # Determine true share
    true_share_to_use = DotOne::Utils.return_meaningful_amount(
      options[:true_share],
      DotOne::Utils.to_percentage(revenue, order_total), # Use true share based on supplied order total and revenue
      DotOne::Utils.to_percentage(skip_existing_payout ? nil : true_pay, self.order_total), # Use true share as derived from this
      true_share_from_record,
    )

    # Calculate order_total_to_use (either by order total or by payout/revenue)
    # This is used to calculate affiliate commission
    order_total_to_use = nil

    # This is used to record the order total as-is from advertiser.
    # It is different than order_total_to_use so if advertiser
    # is paying less than promised, we follow the percentage as
    # set by the advertiser to calculate affiliate commission to avoid
    # overpayment
    order_total_to_record = nil

    if using_true_share || using_affiliate_share
      order_total_to_record = DotOne::Utils.return_meaningful_amount(
        order_total,
        DotOne::Utils.percentage_to_total(true_share_to_use, revenue)
      )

      order_total_to_use = DotOne::Utils.return_meaningful_amount(
        DotOne::Utils.percentage_to_total(true_share_from_record, revenue),
        order_total
      )
    else
      order_total_to_record = DotOne::Utils.return_meaningful_amount(order_total, revenue)
      order_total_to_use = DotOne::Utils.return_meaningful_amount(order_total, revenue)
    end

    # Adjust order total to use with currency multiplier
    unless skip_currency_adjustment
      order_total_to_record *= multiplier
      order_total_to_use *= multiplier
    end

    order_total_to_record = DotOne::Utils.return_meaningful_amount(order_total_to_record, true_pay_from_record)
    order_total_to_use = DotOne::Utils.return_meaningful_amount(order_total_to_use, true_pay_from_record)

    affiliate_share_from_record = 0
    affiliate_pay_from_record = 0

    if using_affiliate_share
      affiliate_share_from_record = DotOne::Utils.return_meaningful_amount(
        options[:affiliate_share],
        snapshot&.dig(:affiliate_share),
        step_price&.custom_share,
        conv_step.affiliate_share
      )
    else
      affiliate_pay_from_record = DotOne::Utils.return_meaningful_amount(
        snapshot&.dig(:affiliate_pay),
        step_price&.custom_amount,
        conv_step.affiliate_pay
      )

      affiliate_pay_from_record *= multiplier unless skip_currency_adjustment
    end

    # Determine affiliate share
    affiliate_share_to_use = DotOne::Utils.return_meaningful_amount(
      options[:affiliate_share],
      DotOne::Utils.to_percentage(supplied_affiliate_pay, order_total_to_record), # Use affiliate share as calculated from supplied commission
      # Use affiliate share as derived from this transaction if exist
      # This is necessary when we want to approve pending transaction
      # without supplying any commission. This will ensure that the
      # true affiliate share is used
      DotOne::Utils.to_percentage(skip_existing_commission ? nil : affiliate_pay, order_total_to_record),
      affiliate_share_from_record
    )

    # Calculate payout
    payout = DotOne::Utils.return_meaningful_amount(supplied_revenue, supplied_true_pay)

    if using_true_share
      payout = DotOne::Utils.return_meaningful_amount(
        payout,
        DotOne::Utils.percentage_to_amount(true_share_to_use, order_total_to_use)
      )
    else
      payout = DotOne::Utils.return_meaningful_amount(payout, true_pay_from_record)

      true_share_to_use = DotOne::Utils.to_percentage(payout, order_total_to_record)

      if using_affiliate_flat_rate
        order_total_to_use = [payout, true_pay_from_record].min
        affiliate_share_to_use = DotOne::Utils.to_percentage(affiliate_pay_from_record, true_pay_from_record)
      end
    end

    if (using_true_share || options[:allow_zero] == true) && revenue.present? && revenue.to_f == 0
      payout = 0
      order_total_to_use = 0
      true_share_to_use = 0
    end

    # Calculate commission
    commission = DotOne::Utils.return_meaningful_amount(
      supplied_affiliate_pay,
      skip_existing_commission ? nil : affiliate_pay,
      DotOne::Utils.percentage_to_amount(affiliate_share_to_use, order_total_to_use),
      affiliate_pay_from_record
    )

    commission = 0 if revenue.present? && payout == 0

    affiliate_share_to_use = DotOne::Utils.to_percentage(commission, order_total_to_record)

    # Round payout & commission when applicable
    if Currency.integer_currency_code?(Currency.platform_code)
      payout = payout.round if using_true_flat_rate
      commission = commission.round if using_affiliate_flat_rate
    end

    margin = payout - commission

    true_share_from_record,
    true_share_to_use,
    true_pay_from_record,
    order_total_to_record,
    order_total_to_use,
    affiliate_share_from_record,
    affiliate_share_to_use,
    affiliate_pay_from_record,
    payout,
    commission,
    margin = [
      true_share_from_record,
      true_share_to_use,
      true_pay_from_record,
      order_total_to_record,
      order_total_to_use,
      affiliate_share_from_record,
      affiliate_share_to_use,
      affiliate_pay_from_record,
      payout,
      commission,
      margin
    ]
    .map { |value| value.to_f.round(2) }

    puts "[CALCULATOR] skip currency adjustment: #{skip_currency_adjustment}"
    puts "[CALCULATOR] true_share_from_record: #{true_share_from_record}"
    puts "[CALCULATOR] true_share_to_use: #{true_share_to_use}"
    puts "[CALCULATOR] true_pay_from_record: #{true_pay_from_record}"
    puts "[CALCULATOR] order_total_to_record: #{order_total_to_record}"
    puts "[CALCULATOR] order_total_to_use: #{order_total_to_use}"
    puts "[CALCULATOR] affiliate_share_from_record: #{affiliate_share_from_record}"
    puts "[CALCULATOR] affiliate_share_to_use: #{affiliate_share_to_use}"
    puts "[CALCULATOR] affiliate_pay_from_record: #{affiliate_pay_from_record}"
    puts "[CALCULATOR] payout: #{payout}"
    puts "[CALCULATOR] commission: #{commission}"
    puts "[CALCULATOR] margin: #{margin}"

    true_share_to_use = DotOne::Utils.return_meaningful_amount(true_share_to_use, true_share_from_record)
    affiliate_share_to_use = DotOne::Utils.return_meaningful_amount(affiliate_share_to_use, affiliate_share_from_record)

    [
      conv_step,
      step_price,
      order_total_to_record,
      payout,
      commission,
      true_share_to_use,
      affiliate_share_to_use,
      snapshot,
      margin,
      currency_rate_map,
    ]
  end

  private

  def print_attributes(attrs)
    attrs.map do |key, value|
      if value.is_a?(BigDecimal)
        [key, value.to_f]
      else
        [key, value]
      end
    end.to_h
  end
end
