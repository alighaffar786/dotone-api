class BotStatCollection < AffiliateStatCollection
  attr_reader :date_type

  def initialize(relation, params = {}, **options)
    super
    @date_type = :recorded_at
    @relation = BotStat.accessible_by(ability)
  end

  def ensure_filters
    filter_by_statuses if params[:statuses].present?
    filter_by_search if params[:search].present?
    filter_by_approvals if params[:approvals].present?
    filter_by_date if params[:start_date].present? || params[:end_date].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_event_offer_ids if params[:event_offer_ids].present?
    filter_by_excluded_offer_ids if params[:excluded_offer_ids].present?
    filter_by_excluded_network_ids if params[:excluded_network_ids].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_billing_region if params[:billing_region].present?
    filter_by_negative_margin if truthy?(params[:negative_margin])
    filter_by_exclude_order_apis if truthy?(params[:exclude_order_apis]) || falsy?(params[:exclude_order_apis])
    filter_by_zero_margin if truthy?(params[:zero_margin])
  end

  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end
end
