module AffiliateStatHelpers::ConversionHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def find_order(stat, options = {})
      order_number = options[:order_number]
      conv_step = options[:conversion_step] || stat.conversion_step

      order = nil
      original_id = stat.original_id
      offer_id = stat.offer_id

      if order_number.present?
        orders = Order.where(
          affiliate_stat_id: original_id,
          order_number: order_number,
          step_name: conv_step.name,
          offer_id: offer_id,
        ).to_a

        if orders.empty?
          orders = Order.where(
            order_number: order_number,
            step_name: conv_step.name,
            offer_id: offer_id,
          ).to_a

          # Exclude step name on lookup if no converted order
          # found - this is to handle step name change
          # in the system
          if orders.empty?
            orders = Order.where(order_number: order_number, offer_id: offer_id).to_a
          end
        end

        puts "_ORDER_NUMBER: #{order_number}"
        puts "STEP NAME: #{conv_step.name}"
        puts "OFFER ID: #{offer_id}"

        puts "ID: #{stat.id}"

        puts "CONVERTED ORDERS: #{orders.map(&:id)} -- #{orders.size}"

        order = orders.find do |order|
          raise "Order #{order.id} has no copy stat" if order.copy_stat.blank?

          puts "CACHED COPY STAT: #{order.copy_stat.id}"
          puts "CACHED AFFILIATE STAT: #{order.affiliate_stat_id}"
          stat.conversions? && stat.order_id == order.id || stat.clicks? && stat.id == order.affiliate_stat_id
        end

        order ||= orders.last if stat.clicks?

        puts "CONVERTED ORDER: #{order&.id || 'NOT FOUND'}"
      elsif original_id
        order = Order
          .where(affiliate_stat_id: original_id, offer_id: offer_id, step_name: conv_step.name)
          .where('order_number LIKE ?', "AUTO-#{stat.network_id}-%")
          .last
      end

      order ||= stat.copy_order if stat.conversions?

      order
    end

    def raise_error_when_approval_change_invalid(stat, conversion_options, options)
      return unless stat.conversions?

      user_role = conversion_options.user_role

      if conversion_options.skip_approved_transaction && stat.considered_approved?
        raise DotOne::Errors::TransactionError::ApprovedStateModificationError, stat.error_payload
      end

      # CHECK: No modification on approved status
      if user_role == :network && stat.considered_approved?(user_role)
        raise DotOne::Errors::TransactionError::FinalStateModificationError, stat.error_payload
      end

      # CHECK: No modification on final status
      # Make sure we have order recorded in our system since recording new order
      # will not actually trigger this. This is only applicable to existing conversions/orders
      user_role = options[:real_time] ? :owner : user_role
      if conversion_options.no_modification_on_final_status && stat.considered_final?(user_role)
        raise DotOne::Errors::TransactionError::FinalStateModificationError, stat.error_payload
      end
    end

    def raise_error_when_order_status_check_invalid(stat, check_result = {})
      if check_result[:is_expired] == true
        raise DotOne::Errors::TransactionError::ConversionExpiredError, stat.error_payload
      end

      if check_result[:is_duplicate_order] == true || check_result[:is_duplicate_ip] == true
        raise DotOne::Errors::InvalidDataError.new(stat.error_payload, 'data.duplicate_order')
      end

      if check_result[:is_duplicate_adv_uniq_id] == true
        raise DotOne::Errors::InvalidDataError.new(stat.error_payload, 'data.duplicate_advertiser_uniq_id')
      end

      # CHECK: Duplicate Order - when order number and step name combination already exists
      if duplicate_order = converted_order&.errors.present? && converted_order.errors.keys.include?(:order_number)
        raise DotOne::Errors::InvalidDataError.new(stat.error_payload, 'data.duplicate_order')
      end

      # CHECK: cap
      if check_result[:is_cap_exceeded] == true
        raise DotOne::Errors::TransactionError::CapExceededError, stat.error_payload
      end
    end

    def check_on_order_status(stat, options = {})
      order_status = options[:order_status] || stat.determine_order_status(options)

      check_result = {
        order_status: order_status
      }

      return check_result if options[:skip_order_status_check] == true

      # Skip expiration check when specified (for manual conversion via UI)
      skip_expiration = options[:skip_expiration_check] == true

      # Skip duplicate ip check when specified (for manual conversion via UI)
      skip_duplicate_ip = options[:skip_duplicate_ip_check] == true

      skip_proximity_order = options[:skip_proximity_order] == true

      # CHECK: Expiration - captured and click time difference is more than the days to expire
      if proceed_with_next_check?(order_status) && !skip_expiration
        check_result.merge!(stat.expired_period_on_referral?(options))
        order_status = check_result[:order_status] if check_result[:is_expired] == true
      end

      # CHECK: duplicate by ip address & offer id
      if proceed_with_next_check?(order_status) && !skip_duplicate_ip && stat.cached_offer&.enforce_uniq_ip == true
        check_result.merge!(stat.duplicate_on_ip?(options))
        order_status = check_result[:order_status] if check_result[:is_duplicate_ip] == true
      end

      # CHECK: Duplicate by Proximity Orders - when similar orders exist.
      # if proceed_with_next_check?(order_status) && !skip_proximity_order
      #   check_result.merge!(stat.duplicate_on_proximity_order?(options))
      #   order_status = check_result[:order_status] if check_result[:is_duplicate_order] == true
      # end

      # CHECK: Duplicate by Advertiser Uniq ID
      if proceed_with_next_check?(order_status)
        check_result.merge!(stat.duplicate_on_adv_uniq_id?(options))
        order_status = check_result[:order_status] if check_result[:is_duplicate_adv_uniq_id] == true
      end

      if proceed_with_next_check?(order_status)
        check_result.merge!(stat.check_on_reach_exceed_cap?(options))
        order_status = check_result[:order_status] if check_result[:is_cap_exceeded] == true
      end

      check_result
    end

    # Make sure if order status still need to be checked
    # for other things down the road
    def proceed_with_next_check?(order_status)
      return true if order_status.blank?

      [
        Order.status_pending,
        Order.status_confirmed,
        Order.status_approved,
      ].include?(order_status)
    end
  end

  def duplicate_on_adv_uniq_id?(options = {})
    result = {
      is_duplicate_adv_uniq_id: false,
      order_status: determine_order_status(options),
    }

    return result unless adv_uniq_id = options[:adv_uniq_id].presence

    stats = AffiliateStat.where.not(id: id).where(adv_uniq_id: adv_uniq_id, offer_id: offer_id)

    if stats.exists?
      result.merge!(
        is_duplicate_adv_uniq_id: true,
        order_status: Order.status_duplicate_advertiser_uniq_id,
      )
    end

    result
  end

  def duplicate_on_ip?(options = {})
    result = {
      is_duplicate_ip: false,
      order_status: determine_order_status(options),
    }

    conv_step = options[:conversion_step].presence || conversion_step

    return result unless conv_step

    stats = AffiliateStat
      .conversions
      .where.not(id: id)
      .where(ip_address: ip_address, offer_id: offer_id, step_name: conv_step.name)

    if stats.exists?
      result.merge!(
        is_duplicate_ip: true,
        order_status: Order.status_duplicate_ip,
      )
    end

    result
  end

  def duplicate_on_proximity_order?(options = {})
    result = {
      is_duplicate_order: false,
      order_status: determine_order_status(options),
    }

    conv_step = options[:conversion_step].presence || conversion_step

    return result unless conv_step

    if options[:order].blank?
      proximity_orders = Order
        .where(offer_id: offer_id, affiliate_id: affiliate_id, affiliate_stat_id: original_id, step_name: conv_step.name)
        .where('recorded_at > ?', 15.minutes.ago)

      if proximity_orders.exists?
        result.merge!(
          is_duplicate_order: true,
          order_status: Order.status_duplicate_order,
        )
      end
    end

    result
  end

  def expired_period_on_referral?(options = {})
    result = {
      is_expired: false,
      order_status: determine_order_status(options),
    }

    return result if options[:skip_expiration] == true

    conv_step = options[:conversion_step].presence || conversion_step

    return result unless conv_step

    captured_time = self.captured_at

    if options[:captured_at].present?
      begin
        captured_time ||= DotOne::Utils.to_datetime(options[:captured_at])
      rescue
        Sentry.capture_exception(e) if Rails.env.production?
      end
    end

    captured_time ||= Time.now

    click_time = self.recorded_at

    if options[:recorded_at].present?
      begin
        click_time ||= DotOne::Utils.to_datetime(options[:recorded_at])
      rescue
        Sentry.capture_exception(e) if Rails.env.production?
      end
    end

    expiration = conv_step.days_to_expire.to_i

    # Default to 7 day expiration for session options.
    expiration = 7 if conv_step.session_option == true

    if (captured_time.to_time - click_time.to_time) > expiration.days.to_i
      result.merge!(
        is_expired: true,
        order_status: Order.status_beyond_referral_period,
      )
    end

    result
  end

  def check_on_reach_exceed_cap?(options = {})
    result = {
      is_cap_exceeded: false,
      order_status: determine_order_status(options),
    }

    if reach_exceed_cap?
      result.merge!(
        is_cap_exceeded: true,
        order_status: Order.status_exceed_cap,
      )
    end

    result
  end

  # Method to help determine which order status to use.
  def determine_order_status(options = {})
    order_status = options[:conversion_step]&.default_order_status(options)
    order_status ||= conversion_step&.default_order_status(options)
    order_status
  end
end
