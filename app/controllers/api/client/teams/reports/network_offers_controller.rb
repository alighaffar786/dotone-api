class Api::Client::Teams::Reports::NetworkOffersController < Api::Client::Teams::BaseController
  def campaign_count
    authorize! :read, NetworkOffer
    @counts = paginate(query_campaign_count)
    respond_with_pagination @counts,
      stat_template: stat_template,
      stats: query_stats,
      each_serializer: Teams::NetworkOffer::CampaignCountSerializer
  end

  private

  def query_offers
    network_offers = NetworkOffer.accessible_by(current_ability)
    network_offers = network_offers.where(id: params[:offer_ids]) if params[:offer_ids].present?
    network_offers
  end

  def query_campaigns(offer_ids)
    affiliate_offers = AffiliateOffer.where(offer_id: offer_ids)
    affiliate_offers = affiliate_offers.where(approval_status: params[:approval_statuses]) if params[:approval_statuses].present?
    affiliate_offers = affiliate_offers.between(params[:start_date], params[:end_date], :created_at, current_time_zone, any: true) if params[:start_date].present? || params[:end_date].present?
    affiliate_offers
  end

  def query_campaign_count
    query_campaign_count = query_campaigns(query_offers)
      .select('offer_id, COUNT(*) AS count')
      .preload(offer: [:name_translations])
      .group(:offer_id)
    query_campaign_count = query_campaign_count.order("#{params[:sort_field]} #{params[:sort_order]}") if params[:sort_field].present?
    query_campaign_count
  end

  def query_stats
    query_campaigns(@counts.map(&:offer_id))
      .select("offer_id, DATE_FORMAT(created_at, '%Y/%m') AS date, COUNT(*) AS count")
      .where("created_at >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 12 MONTH), '%Y-%m-01')")
      .group("offer_id, DATE_FORMAT(created_at, '%Y/%m')")
      .group_by(&:offer_id)
  end

  def stat_template
    (0..11).map { |i| [i.months.ago.strftime('%Y/%m'), 0] }.to_h
  end
end
