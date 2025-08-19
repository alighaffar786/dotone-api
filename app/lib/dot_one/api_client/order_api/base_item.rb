##
# Module that is being shared by class implementing Order Item
# on OrderApi.

module DotOne::ApiClient::OrderApi
  class BaseItem
    CACHE_EXPIRATION = {
      expires_in: 2.days,
    }

    CACHE_STORE = ActiveSupport::Cache::FileStore.new("#{Rails.root}/tmp/cache/api-pull/#{Date.today}")

    # Our unique transaction ID (Click ID)
    # that we forwarded to our advertisers.
    # The value is required to record orders/conversions
    # from their end to our database
    attr_accessor :click_stat

    # Timestamp of when the order/conversion is captured.
    # This can be from the advertiser or we decide it ourselves.
    # However - at the time of this writing - we decided
    # to use our own timestamp because timestamp from our advertiser
    # is unreliable. This timestamp needs to be in local timezone
    attr_accessor :recorded_at

    # Timestamp for when pending order/conversion becomes
    # approved or rejected. This also uses our own timestamp
    # for the same reason :recorded_at has. This timestamp needs
    # to be in local timezone
    attr_accessor :converted_at

    # Unique ID that our advertiser generates to indicate
    # a conversion from their end. This is their unique ID,
    # not ours
    attr_accessor :order_number

    # Total revenue that the advertiser gain. This is not
    # the commission that we are getting. For e-commerce,
    # this is the total shopping cart that they are getting
    attr_accessor :total

    # Commission that we are getting from the advertiser
    attr_accessor :true_pay

    # Commission that we are paying out to the affiliate
    attr_accessor :affiliate_pay

    # Status of the conversion/order. We only recognize
    # three status: APPROVED, PENDING, REJECTED. Any status
    # from the advertiser needs to be mapped to those three.
    # APPROVED:
    #   conversion is approved, commission is payable to us
    # PENDING:
    #   conversion is pending, we are still waiting for
    #   advertiser final decision on whether the conversion
    #   is approved or rejected in a later time
    # REJECTED:
    #   conversion is rejected, commission is not payable to us
    #   due to fraud, chargebacks, order cancellation,
    #   order returns, etc
    attr_accessor :status

    # This is a true/false flag that indicate
    # if this advertiser allows one click to generate
    # multiple conversion. This value is determined
    # on the business contract level. Contact sales rep
    # or refer to platform on what the value of this is
    attr_accessor :is_multiple_conversion_point

    # Any conversion point name that is supplied
    # from the advertiser via API. This step_name
    # is used to find the exact price point we need
    # to use in calculating payout and commission
    attr_accessor :step_name

    attr_accessor :click_stat_id

    # Mark current item to finalize the conversion during processing.
    # Each API client has different way to differentiate what's constitute
    # as final transaction. So, this will be set on client by client basis
    attr_accessor :finalize

    # Alter the no modification on final status
    # in order to allow changes to transactions with final status
    attr_accessor :no_modification_on_final_status

    # Tell what to do (:approve or :reject) when negative
    # margin is encountered. Some API Client might want
    # to set it to :approve as part of order returns or chargebacks
    attr_accessor :on_negative_margin

    # Helper attribute comtaining order number without
    # SKU or unique string
    attr_accessor :order_number_only

    # Helper attribute comtaining order number with SKU
    attr_accessor :order_number_with_sku

    # Helper attribute comtaining order number with SKU &
    # another unique string
    attr_accessor :order_number_with_unique_string

    attr_accessor :record

    def self.order_map
      CACHE_STORE.fetch(api_cache_key('order_map')) || {}
    end

    def self.order_map=(map)
      CACHE_STORE.write(api_cache_key('order_map'), map, CACHE_EXPIRATION)
    end

    def self.transaction_map
      CACHE_STORE.fetch(api_cache_key('transaction_map')) || {}
    end

    def self.transaction_map=(map)
      CACHE_STORE.write(api_cache_key('transaction_map'), map, CACHE_EXPIRATION)
    end

    def self.copy_stat_map
      CACHE_STORE.fetch(api_cache_key('copy_stat_map')) || {}
    end

    def self.copy_stat_map=(map)
      CACHE_STORE.write(api_cache_key('copy_stat_map'), map, CACHE_EXPIRATION)
    end

    def self.api_cache_key(postfix)
      key = [self.class.name, postfix].join('-')
      DotOne::Utils::Encryptor.hexdigest(key)
    end

    def initialize(record)
      @record = record
    end

    ##
    # Method to convert this item to Order. In doing so, it will require
    # AffiliateStat of the original click as well as the conversion step in calculating
    # the commission share/rate.
    def to_stat(options = {})
      raise 'Click Stat is Unknown' if @click_stat.blank?
      raise 'Offer is Set to Skip API' if @click_stat.cached_offer.skip_order_api?
      raise 'Conversion Point is Unknown' if conversion_step.blank?
      raise 'Offer Variant is Unknown' if offer_variant.blank?
      raise 'Stat is marked to skip API Refresh' if skip_api_refresh?

      if copy_stat && copy_stat.order_total == 0 && copy_stat.true_pay == 0
        @no_modification_on_final_status = false
      end

      if @is_multiple_conversion_point
        if no_modification_on_final_status && copy_stat && (!finalize && !copy_stat.considered_pending?(:network) ||
          finalize && (copy_stat.considered_approved? || copy_stat.considered_rejected?))
          raise 'Order is in final state'
        end

        raise 'Order number is missing' if order_number.blank?
      end

      delayed_process = options[:delayed] == true

      stat_to_process = copy_stat || @click_stat

      process_options = {
        skip_mca_check: true,
        skip_offer_status: true,
        skip_order_status_check: true,
        skip_revert_no_campaign: true,
        skip_existing_commission: true,
        on_negative_margin: (on_negative_margin || :reject),
        approval: @status,
        captured_at: TimeZone.current.to_utc(@recorded_at),
        trace_custom_agent: 'System - API',
        reload_transaction: true,
      }

      conversion_options = DotOne::Utils::ConversionOptions.new
      conversion_options.no_modification_on_final_status = no_modification_on_final_status

      if finalize
        conversion_options = DotOne::Utils::ConversionOptions.new(
          user_role: :owner,
          skip_set_to_published: true,
          skip_approved_transaction: true,
          is_payment_received: true,
        )
      end

      if @is_multiple_conversion_point
        process_options[:step] = step_name
        process_options[:step] = conversion_step.name if process_options[:step].blank?
        process_options[:order] = @order_number
      end

      process_options[:order_total] = @total.to_f.round(2) if @total.present?

      process_options[:revenue] = @true_pay.to_f.round(2) if @true_pay.present?

      process_options[:affiliate_pay] = @affiliate_pay.to_f.round(2) if @affiliate_pay.present?

      process_options[:converted_at] = TimeZone.current.to_utc(@converted_at) if @converted_at.present?

      if options[:converted_at].present?
        process_options[:converted_at] = DotOne::Utils.to_datetime("#{options[:converted_at]} 23:59:59")
        process_options[:converted_at] = TimeZone.current.to_utc(process_options[:converted_at])
      end

      # Override Approved status with Published when necessary
      if !finalize && @click_stat.set_to_published_instead?(conversion_options, process_options)
        process_options[:approval] = AffiliateStat.approval_published
        process_options[:converted_at] = nil
      end

      return if stat_to_process.blank?

      if delayed_process
        AffiliateStats::ConversionJob.perform_later(stat_to_process.id, conversion_options, process_options)
      else
        stat_to_process.process_conversion!(conversion_options, process_options)
      end
    end

    # Obtain conversion step from stat.
    # We are assuming the offer variant to only have one conversion step, the default conversion step.
    def conversion_step
      return if offer.blank?

      offer.cached_default_conversion_step
    end

    def offer_variant
      @click_stat.cached_offer_variant
    end

    def offer
      @click_stat&.cached_offer
    end

    def network
      @click_stat&.cached_network
    end

    # Obtain order based on current click stat
    def order(options = {})
      console = options[:console] || false
      raise 'No Click Stat' if @click_stat.blank?
      raise 'No Order Number' if @is_multiple_conversion_point && @order_number.blank?

      return unless @is_multiple_conversion_point

      current_order = self.class.order_map[[@click_stat.id, @order_number].join('-')]
      puts "ORDER FROM MAP: #{current_order.id}" if current_order.present? && console
      if current_order.blank? && self.class.order_map.blank?
        current_order = Order.find_by(order_number: @order_number, affiliate_stat_id: @click_stat.id)
      end

      current_order
    end

    def copy_stat
      return unless @is_multiple_conversion_point
      return if order.blank?

      @copy_stat ||= self.class.copy_stat_map[order.id] || order&.copy_stat
      @copy_stat
    end

    def pending?
      if @is_multiple_conversion_point
        order.present? && copy_stat.present? &&
          copy_stat.pending?
      else
        @click_stat.pending?
      end
    end

    def skip_api_refresh?
      current_stat = copy_stat
      current_stat = @click_stat if current_stat.blank?
      current_stat && current_stat.skip_api_refresh?
    end

    # For those API client that does not have
    # a true captured time, we will determine
    # it by detecting whether this order is new
    def use_own_captured_at
      return if @click_stat.blank?

      if @is_multiple_conversion_point
        return if @order_number.blank?

        current_order = order

        if current_order.present?
          current_order.recorded_at
        else
          Time.now
        end
      else
        return @click_stat.captured_at if @click_stat.present?

        Time.now
      end
    end

    # For those API client that does not have
    # a true conversion time, we will determine
    # conversion time ourselves by detecting
    # a change in status
    def use_own_converted_at
      return if @click_stat.blank?

      return unless AffiliateStat.approvals_considered_final.include? @status

      if @is_multiple_conversion_point
        return if @order_number.blank?

        current_order = order

        current_order&.converted_at.presence || Time.now
      else
        @click_stat.converted_at || Time.now
      end
    end

    def obtain_transaction(transaction_id)
      self.click_stat_id = transaction_id
      return AffiliateStat.clicks.first if Rails.env == 'development'

      to_return = self.class.transaction_map&.fetch(transaction_id, nil)

      to_return = AffiliateStat.find_by_id(transaction_id) if to_return.blank?

      raise DotOne::Errors::AffiliateStatNotFoundError.new(transaction_id, order_number, 'Click stat not found') if to_return.blank? || !to_return.clicks?

      to_return
    end

    def order_number_to_record
      raise 'No Click Stat' if @click_stat.blank?

      raise 'No Order Number' if @is_multiple_conversion_point && @order_number_only.blank?

      return unless @is_multiple_conversion_point

      [@order_number_with_unique_string, @order_number_with_sku, @order_number_only].each do |number|
        current_order = number && Order.find_by(order_number: number, affiliate_stat_id: @click_stat.id)

        return number if current_order.present?
      end

      @order_number_with_unique_string || @order_number_with_sku || @order_number_only
    end

    def log_it!
      notes = ["[#{Time.now}] Itemize #{self.class.name.split('::')[2]} ORDER: #{order_number}"]
      notes << "OFFER: #{offer.id_with_name}" if offer
      notes << "ADVERTISER: #{network.id_with_name}" if network
      notes << "CAPTURED AT: #{use_own_captured_at.to_s(:db)}" if use_own_captured_at

      ORDER_API_PULL_LOGGER.warn(notes.join(' '))
    end
  end
end
