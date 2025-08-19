class DotOne::AffiliateStats::Importer::Finder
  attr_reader :data, :original_stat, :copy_stat, :warnings, :stats, :skip_requested

  def initialize(data, options = {})
    @skip_requested = false
    @data = data
    @stats = options[:stats]
    @trace_agent_via = options[:trace_agent_via]

    @original_stat = AffiliateStat.find_by_id(@data[:id])&.original
    @order_number = @data[:order_number]
    @sku_order_number = [@data[:order_number], @data[:sku]].compact_blank.join(':')
    @order_number_to_use = @sku_order_number

    @warnings = []
  end

  ##
  # Get the parent and copy stat for further processing.
  # Any duplicate orders will fail this process and raise exception
  def lookup
    result = []
    current_approval = data[:current_approval].presence

    if @copy_stat = lookup_copy_stat
      @data[:order_number] = @order_number_to_use = copy_stat.order_number
      @skip_requested = current_approval.present? && copy_stat.approval != current_approval

      result = [copy_stat.original, copy_stat]
    elsif original_stat.present?
      @skip_requested = current_approval.present? && (original_stat.cached_offer&.multi? ? true : original_stat.approval != current_approval)

      result = [original_stat, nil]
    elsif original_stat.blank? && data[:offer_id].present?
      if current_approval.present?
        @skip_requested = true
      else
        @original_stat = create_manual_click

        result = [original_stat, nil]
      end
    end

    log_warnings('Skipped') if @skip_requested

    result
  end

  private

  # Lookup information based on order number and original stat
  def lookup_copy_stat
    copy_stat = nil

    [@sku_order_number, @order_number].each do |order_number|
      copy_stat ||= stats.find do |stat|
        stat.order_number == order_number && stat.original_id == original_stat&.id ||
        stat.order_number == order_number && stat.offer_id.to_i == data[:offer_id].to_i && stat.step_name == data[:step_name] ||
        stat.order_number == order_number && stat.offer_id.to_i == data[:offer_id].to_i ||
        stat.order_number == order_number && stat.affiliate_id.to_i == data[:affiliate_id].to_i ||
        stat.id == data[:id]
      end
    end

    copy_stat
  end

  ##
  # For new order or conversion, we want to pair
  # it with a transaction. This method helps with
  # creating transaction from the upload data
  def create_manual_click
    # Cannot proceed without any known offer
    unless offer = NetworkOffer.find_by_id(data[:offer_id])
      raise DotOne::Errors::InvalidDataError.new(data, 'data.unknown_offer')
    end

    return if AffiliateStat.approvals_considered_rejected.include?(data[:approval])

    create_click(offer)
  end

  private

  def extract_recorded_at
    data[:captured_at].presence || data[:converted_at].presence || Time.now
  end

  def extract_affiliate_id
    data[:affiliate_id].presence ||
    DotOne::Setup.missing_credit_affiliate_id ||
    Affiliate.first.id
  end

  def create_click(offer)
    AffiliateStat.new.tap do |stat|
      stat.network_id = offer.network_id
      stat.offer_id = offer.id
      stat.offer_variant_id = offer.default_offer_variant.id
      stat.affiliate_id = extract_affiliate_id
      stat.clicks = 1
      stat.status = Order.status_manual_credit
      stat.manual_notes = 'Added during CSV Upload to record new order.'
      stat.recorded_at = extract_recorded_at
      stat.language_id = Language.default.id
      stat.trace_agent_via = @trace_agent_via

      stat.save

      log_warnings("Assigned to New Transaction ID: #{stat.id}")

      stat
    end
  end

  def log_warnings(message)
    @warnings << [data, message].join(': ')
  end
end
