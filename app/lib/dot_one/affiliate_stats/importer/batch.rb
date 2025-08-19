class DotOne::AffiliateStats::Importer::Batch
  attr_accessor :rows, :ability, :user_role, :stat_ids, :offer_ids, :affiliate_ids

  def initialize(rows, options = {})
    @rows = rows
    @ability = options[:ability]
    @user_role = @ability.user.generic_role
    @trace_agent_via = options[:trace_agent_via]
    @warnings = []
    @errors = []
  end

  def self.process(rows, options = {})
    new(rows, options).process
  end

  def process
    authorize_rows
    process_rows
  end

  def authorize_rows
    raise NotImplementedError
  end

  def process_rows
    rows.each do |row|
      process_each_row(row)
    rescue DotOne::Errors::BaseError => e
      ::Rails.logger.error "[ConversionUpload#upload_conversions] #{e.message}"
      ::Rails.logger.error e.backtrace.join("\r\n")
      @errors.push([row, e.full_message].join(': '))
      next
    end

    [@warnings, @errors]
  end

  def process_each_row(row)
    raise NotImplementedError
  end

  class NetworkOffer < DotOne::AffiliateStats::Importer::Batch
    def process_each_row(row)
      # Query and find the correct stat to modify
      # Check data syntax
      # RowValidator can correct/modify given data
      validator = DotOne::AffiliateStats::Importer::RowValidator::NetworkOffer.new(row, user_role: user_role)
      data = validator.validate

      finder = DotOne::AffiliateStats::Importer::Finder.new(data, trace_agent_via: @trace_agent_via, stats: stats)
      original_stat, copy_stat = finder.lookup
      @warnings.push(finder.warnings)

      unless finder.skip_requested
        data = finder.data

        raise DotOne::Errors::InvalidDataError.new(data, 'data.unknown_transaction') if original_stat.blank?

        conversion_options = DotOne::Utils::ConversionOptions.new(row.merge(user_role: user_role))
        skip_calculation = data.slice(:order_total, :true_pay, :true_share, :affiliate_pay, :affiliate_share).values.compact_blank.blank?

        options = {
          user_role: user_role,
          order_number: data[:order_number],
          approval: data[:approval],
          order_total: data[:order_total],
          revenue: data[:true_pay],
          affiliate_pay: data[:affiliate_pay],
          true_share: data[:true_share],
          affiliate_share: data[:affiliate_share],
          step_name: data[:step_name].presence || copy_stat&.step_name,
          converted_at: data[:converted_at],
          captured_at: data[:captured_at],
          skip_mca_check: true,
          skip_offer_status: true,
          skip_order_status_check: true,
          skip_revert_no_campaign: true,
          skip_affiliate_status: true,
          skip_calculation: skip_calculation,
          allow_zero: BooleanHelper.truthy?(data[:allow_zero]),
          skip_existing_commission: !skip_calculation,
          skip_existing_payout: data.slice(:order_total, :true_pay, :true_share).values.compact_blank.any?,
          trace_agent_via: @trace_agent_via,
        }

        stat_to_use = copy_stat || original_stat
        result = stat_to_use.process(conversion_options, options)
      end
    end

    def authorize_rows
      @stat_ids = rows.map { |row| row[:id] }.compact_blank.uniq.presence
      @offer_ids = rows.map { |row| row[:offer_id] }.compact_blank.uniq.presence
      @affiliate_ids = rows.map { |row| row[:affiliate_id] }.compact_blank.uniq.presence

      if @stat_ids.present?
        @stat_ids = AffiliateStat.accessible_by(ability).where(id: @stat_ids).pluck(:id)

        @rows = rows.select { |row| @stat_ids.include?(row[:id]) }
      end

      if @offer_ids.present?
        @offer_ids = ::NetworkOffer.accessible_by(ability).where(id: @offer_ids).pluck(:id)

        @rows = rows.select { |row| @offer_ids.include?(row[:offer_id].to_i) }
      end

      if @affiliate_ids.present?
        @affiliate_ids = Affiliate.accessible_by(ability).where(id: @affiliate_ids).pluck(:id)

        @rows = rows.select { |row| @affiliate_ids.include?(row[:affiliate_id].to_i) }
      end
    end

    def click_ids
      return if stat_ids.blank?

      @click_ids ||= AffiliateStat.where(id: stat_ids).map(&:original_id)
    end

    def order_numbers
      values = rows.flat_map do |row|
        order_number = row[:order_number]
        order_number_with_sku = [order_number, row[:sku]].compact_blank.join(':')

        [order_number, order_number_with_sku]
      end
      .compact_blank
      .uniq

      return if values.blank?

      values
    end

    def stats
      return if stat_ids.blank? && offer_ids.blank? && affiliate_ids.blank?

      @stats ||= begin
        result = []

        if order_numbers
          orders = Order.where(order_number: order_numbers)
          orders = orders.where(affiliate_stat_id: click_ids) if click_ids
          orders = orders.where(offer_id: offer_ids) if offer_ids
          orders = orders.where(affiliate_id: affiliate_ids) if affiliate_ids
          orders = orders.preload(:copy_stat)

          result = orders.map(&:copy_stat)
        end

        result += AffiliateStat.conversions.where(id: stat_ids)

        result.uniq
      end
    end
  end

  class EventOffer < DotOne::AffiliateStats::Importer::Batch
    def authorize_rows
      @offer_ids = rows.map { |row| row[:offer_id] }.compact_blank.uniq.presence
      @affiliate_ids = rows.map { |row| row[:affiliate_id] }.compact_blank.uniq.presence

      if @offer_ids.present?
        @offer_ids = ::EventOffer.accessible_by(ability).where(id: @offer_ids).pluck(:id)

        @rows = rows.select { |row| @offer_ids.include?(row[:offer_id].to_i) }
      end

      if @affiliate_ids.present?
        @affiliate_ids = Affiliate.accessible_by(ability).where(id: @affiliate_ids).pluck(:id)

        @rows = rows.select { |row| @affiliate_ids.include?(row[:affiliate_id].to_i) }
      end
    end

    def process_each_row(row)
      validator = DotOne::AffiliateStats::Importer::RowValidator::EventOffer.new(row, user_role: user_role)
      data = validator.validate

      create_single_conversion(data)
    end

    def create_single_conversion(data)
      unless event_offer = ::EventOffer.find_by(id: data[:offer_id])
        raise DotOne::Errors::InvalidDataError.new(data, 'data.unknown_offer')
      end

      attributes = data.slice(:offer_id, :affiliate_id, :true_pay, :affiliate_pay, :approval)

      AffiliateStat.new(attributes).tap do |stat|
        stat.clicks = 1
        stat.conversions = 1
        stat.network_id = event_offer.network_id
        stat.offer_variant_id = event_offer.default_offer_variant.id
        stat.affiliate_id ||= DotOne::Setup.missing_credit_affiliate_id || Affiliate.first.id
        stat.manual_notes = 'Added during CSV Upload to record new order.'
        stat.recorded_at = data[:captured_at].presence || data[:converted_at].presence || Time.now
        stat.captured_at = data[:captured_at].presence || data[:converted_at].presence || Time.now
        stat.converted_at = data[:converted_at].presence
        stat.trace_agent_via = @trace_agent_via
        stat.save!

        stat
      end
    end
  end
end
