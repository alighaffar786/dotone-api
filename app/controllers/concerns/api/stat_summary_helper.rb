module Api::StatSummaryHelper
  def stat_summary_klass
    raise NotImplementedError
  end

  def current_columns
    @current_columns = parse_columns(params[:columns])

    dimensions = @current_columns.include?(:date) ? [:date] : []
    dimensions = dimensions | (stat_summary_klass.dimensions & @current_columns)

    metrics = stat_summary_klass.metrics & @current_columns
    metrics = stat_summary_klass.default_metrics_for(params[:date_type]) if dimensions.present? && metrics.blank?

    @current_columns = dimensions | metrics

    @current_columns |= [:offer_id] if @current_columns.include?(:offer_variant_id)
    @current_columns.delete(:media_categories) if @current_columns.exclude?(:affiliate_id)

    if @current_columns.exclude?(:network_id)
      @current_columns.delete(:contact_lists)

      @current_columns.reject! do |column_name|
        column_name.to_s.start_with?('network_')
      end
    end

    @current_columns
  end

  def instance_options
    if current_columns.include?(:offer_id) && ids = @stats.map(&:offer_id).presence
      offers = Offer.where(id: ids.uniq).preload(:name_translations).index_by(&:id)
    end

    if current_columns.include?(:offer_variant_id) && ids = @stats.map(&:offer_variant_id).presence
      offer_variants = OfferVariant.where(id: ids.uniq).preload(:name_translations).index_by(&:id)
    end

    if current_columns.include?(:image_creative_id) && ids = @stats.map(&:image_creative_id).presence
      image_creatives = ImageCreative.where(id: ids.uniq).index_by(&:id)
    end

    if current_columns.include?(:text_creative_id) && ids = @stats.map(&:text_creative_id).presence
      text_creatives = TextCreative.where(id: ids.uniq).index_by(&:id)
    end

    if current_columns.include?(:affiliate_id) && ids = @stats.map(&:affiliate_id).presence
      affiliates = Affiliate.where(id: ids.uniq).preload(:affiliate_application)
      affiliates = affiliates.preload(:media_categories) if current_columns.include?(:media_categories)
      affiliates = affiliates.index_by(&:id)
    end

    if current_columns.include?(:network_id) && (ids = @stats.map(&:network_id).presence)
      networks = Network.where(id: ids.uniq)
      networks = networks.preload(:country) if current_columns.include?(:network_country)
      networks = networks.preload(:contact_lists) if current_columns.include?(:contact_lists)
      networks = networks.index_by(&:id)
    end

    {
      offers: offers,
      offer_variants: offer_variants,
      image_creatives: image_creatives,
      text_creatives: text_creatives,
      affiliates: affiliates,
      networks: networks,
    }
  end

  def query_stat_summary
    report = stat_summary_klass.new(current_ability, report_params)
    [report.generate, report.total]
  end

  def report_params
    { currency_code: current_currency_code, time_zone: current_time_zone, columns: current_columns }
  end

  def parse_columns(columns)
    arr =
      if columns.is_a?(Array)
        columns.map(&:to_sym).presence
      elsif columns.present?
        columns.to_s.split(',').map(&:to_sym).presence
      end
    arr || []
  end
end
