class Api::Client::Teams::AffiliateSearchLogsController < Api::Client::Teams::BaseController
  def offer_summary
    authorize! :read, AffiliateSearchLog
    @affiliate_search_logs = paginate(query_summary(:offer))
    respond_with_pagination @affiliate_search_logs
  end

  def product_summary
    authorize! :read, AffiliateSearchLog
    @affiliate_search_logs = paginate(query_summary(:product))
    respond_with_pagination @affiliate_search_logs
  end

  private

  def query_summary(keyword_type)
    params[:days_ago] ||= 30
    collection = AffiliateSearchLogCollection.new(current_ability, params).collect
    collection.agg_popularity(keyword_type)
  end
end
