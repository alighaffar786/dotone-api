class AffiliateStatCollection < BaseCollection
  attr_reader :date_type, :data_type

  DATE_TYPES = [:recorded_at, :captured_at, :published_at, :converted_at, :updated_at].freeze

  def initialize(relation, params = {}, **options)
    super(relation, params, **options)

    @data_type = params[:data_type].presence&.to_sym || :clicks
    @date_type = params[:date_type].presence&.to_sym
    @date_type = DATE_TYPES.include?(@date_type) ? @date_type : extract_date_type(@data_type)

    klass_type = extract_date_type(@data_type)
    klass = klass_type == :recorded_at ? AffiliateStat : "AffiliateStat#{klass_type.to_s.classify}".constantize
    @relation = klass.accessible_by(ability)
  end

  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present?
    filter_by_approvals if params[:approvals].present?
    filter_clicks if (data_type == :clicks && !truthy?(params[:conversions])) || truthy?(params[:clicks])
    filter_conversions if truthy?(params[:conversions])
    filter_by_date if params[:start_date].present? || params[:end_date].present?
    filter_by_step_name if params[:step_name].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_event_offer_ids if params[:event_offer_ids].present?
    filter_by_excluded_offer_ids if params[:excluded_offer_ids].present?
    filter_by_excluded_network_ids if params[:excluded_network_ids].present?
    filter_by_variant_ids if params[:offer_variant_ids].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_billing_region if params[:billing_region].present?
    filter_by_negative_margin if truthy?(params[:negative_margin])
    filter_by_subids
    filter_by_dimensions
    filter_by_exclude_order_apis if truthy?(params[:exclude_order_apis]) || falsy?(params[:exclude_order_apis])
    filter_by_zero_margin if truthy?(params[:zero_margin])
  end

  def search_by_order_numbers
    @search_by_order_numbers ||= search_orders
  end

  def search_by_clicks_ids
    @search_by_clicks_ids ||= search_orders(column: :affiliate_stat_id)
  end

  def search_orders(column: :order_number)
    results = []
    slice = 50
    slice = 20 if params[:partial_by]&.to_sym == :contain

    search_params.each_slice(slice).each do |terms|
      documents = Order.es_search_by(terms, partial: partial_match?, partial_by: params[:partial_by], column: column, raw: true, size: 10_000)

      results += documents.results.to_a
    end

    results
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    Sentry.capture_exception(e, extra: { search_field: search_field, search_params: search_params })
    raise e
  end

  def filter_by_dimensions
    DotOne::Reports::Affiliates::StatSummary.dimensions.each do |column|
      filter_name = to_filter_name(column)
      filter { @relation.where(column => params[filter_name]) } if params[filter_name].present?
    end
  end

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], date_type, time_zone, any: true)
    end
  end

  def filter_by_search
    search_method = "filter_by_#{search_field.pluralize}"

    begin
      send(search_method)
    rescue NoMethodError => e
      raise e unless search_method.starts_with?('filter_by_')

      filter do
        @relation = query_for_search(@relation, search_field)
        @relation = @relation.conversions unless data_type == :clicks
        @relation
      end
    end
  end

  def filter_by_ids
    filter do
      @relation = query_for_search(@relation, :id)

      unless data_type == :clicks
        ids = search_by_clicks_ids.map { |order| order.copy_stat.id }
        @relation = @relation.or(@relation.klass.where(id: ids).accessible_by(ability, authorize))
      end

      @relation
    end
  end

  def filter_by_order_numbers
    filter do
      ids = search_by_order_numbers.map do |order|
        if data_type == :clicks
          order.affiliate_stat_id
        else
          order.copy_stat.id
        end
      end

      @relation.where(id: ids.uniq)
    end
  end

  def filter_by_statuses
    filter { @relation.where(status: params[:statuses]) }
  end

  def filter_by_approvals
    approvals = [params[:approvals]].flatten

    if network? && approvals.include?(AffiliateStat.approval_pending)
      approvals |= AffiliateStat.approvals_considered_pending(:network)
    end

    filter { @relation.where(approval: approvals) }
  end

  def filter_clicks
    filter { @relation.clicks }
  end

  def filter_conversions
    filter { @relation.conversions }
  end

  def filter_by_step_name
    filter { @relation.where(step_name: params[:step_name]) }
  end

  def filter_by_offer_ids
    filter do
      @relation.where(offer_id: to_array(params[:offer_ids]))
    end
  end

  def filter_by_excluded_offer_ids
    filter do
      @relation.where.not(offer_id: params[:excluded_offer_ids])
    end
  end

  def filter_by_excluded_network_ids
    filter do
      @relation.where.not(network_id: params[:excluded_network_ids])
    end
  end

  def filter_by_variant_ids
    filter { @relation.where(offer_variant_id: params[:offer_variant_ids]) }
  end

  def filter_by_network_ids
    filter { @relation.where(network_id: params[:network_ids]) }
  end

  def filter_by_affiliate_ids
    filter { @relation.where(affiliate_id: params[:affiliate_ids]) }
  end

  def filter_by_billing_region
    filter do
      @relation.with_billing_regions(params[:billing_region])
    end
  end

  def filter_by_event_offer_ids
    filter do
      @relation.where(offer_id: params[:event_offer_ids])
    end
  end

  def filter_by_subids
    filter do
      [:subid_1s, :subid_2s, :subid_2s, :subid_3s, :subid_4s, :subid_5s].each do |subid|
        value = to_array(params[subid])
        next if value.blank?

        @relation = @relation.where(subid.to_s.singularize => value)
      end

      @relation
    end
  end

  def filter_by_negative_margin
    filter { @relation.negative_margin }
  end

  def filter_by_exclude_order_apis
    if truthy?(params[:exclude_order_apis])
      filter { @relation.where.not(network_id: ClientApi.order_api.considered_active.pluck(:owner_id))}
    elsif falsy?(params[:exclude_order_apis])
      filter { @relation.where(network_id: ClientApi.order_api.considered_active.pluck(:owner_id))}
    else
      @relation
    end
  end

  def filter_by_zero_margin
    filter { @relation.zero_margin }
  end

  def default_sorted
    sort { @relation.order(date_type => :desc) }
  end

  def sort_by_offer_name
    sort { @relation.left_outer_joins(:offer).order("offers.name #{sort_order}") }
  end

  def extract_date_type(data_type)
    if data_type == :clicks
      :recorded_at
    else
      "#{data_type}_at".to_sym
    end
  end

  def partial_match?
    @partial_match ||= params[:field]&.include?('partial')
  end

  def search_field
    return @field if @field.present?

    @field = params[:field].presence || 'id'
    @field = @field.gsub('partial_', '') if partial_match?
    @field
  end

  def search_params
    @search_params ||= [params[:search]].flatten.map { |item| item.to_s.squish.presence }.compact.uniq
  end

  def query_for_search(relation, field)
    if partial_match?
      result = nil

      search_params.each do |param|
        result = if result
          result.or(relation.where("#{field} LIKE ?", "%#{param}%"))
        else
          relation.where("#{field} LIKE ?", "%#{param}%")
        end
      end

      result
    else
      relation.where(field => search_params)
    end
  end

  def to_array(value)
    return [] if value.blank?

    value.is_a?(Array) ? value : value.split(',')
  end
end
