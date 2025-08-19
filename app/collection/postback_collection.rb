class PostbackCollection < BaseCollection
  def ensure_filters
    super
    filter_by_affiliate_stat if params[:affiliate_stat_id].present?
    filter_by_exclude_api if truthy?(params[:exclude_api])
    filter_by_postback_type if params[:postback_type].present?
    filter_by_date if params[:start_date].present? && params[:end_date].present?
  end

  protected

  def filter_by_affiliate_stat
    filter do
      affiliate_stat = AffiliateStat.clicks.find(params[:affiliate_stat_id])
      @relation.where(affiliate_stat_id: affiliate_stat.related_stat_ids)
    end
  end

  def filter_by_exclude_api
    filter { @relation.api_excluded }
  end

  def filter_by_date
    filter { @relation.between(params[:start_date], params[:end_date], :recorded_at, time_zone) }
  end

  def filter_by_search
    search_params = params[:search]
    search_params = params[:search].split(',').map(&:squish) if params[:search].is_a?(String)

    filter { @relation.like(search_params) }
  end

  def filter_by_postback_type
    filter { @relation.where(postback_type: params[:postback_type]) }
  end

  def default_sorted
    sort { @relation.order(recorded_at: :desc) }
  end
end
