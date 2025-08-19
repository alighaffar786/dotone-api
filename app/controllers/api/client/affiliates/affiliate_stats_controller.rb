class Api::Client::Affiliates::AffiliateStatsController < Api::Client::Affiliates::BaseController
  include Api::Client::AffiliateStatsHelper

  before_action :validate_stat_start_date

  def index
    authorize! :read, AffiliateStat
    @affiliate_stats = paginate(query_index)
    respond_with_pagination @affiliate_stats, **instance_options.merge(
      meta: { search_key: params[:search_key], search_params: search_params }
    )
  end

  def recent
    authorize! :read, AffiliateStat
    @affiliate_stats = query_recent
    respond_with(
      @affiliate_stats,
      conversion_steps: query_conversion_steps(@affiliate_stats),
      each_serializer: Affiliates::AffiliateStat::RecentSerializer
    )
  end

  def download
    @download = build_stat_download(query_index)
    authorize! :create, @download

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = AffiliateStatCollection.new(current_ability, params, **current_options).collect
    collection = collection.preload(copy_order: :affiliate_stat, offer: :name_translations)
    collection = collection.preload(copy_order: :conversion_steps) unless data_type == :clicks
    collection
  end

  def query_recent
    date_range = current_time_zone.local_range(:last_7_days)
    recent_params = params.merge(start_date: date_range[0], end_date: date_range[1])

    AffiliateStatCollection.new(current_ability, recent_params, **current_options)
      .collect
      .non_invalid
      .non_rejected
      .preload(:copy_order, :offer)
      .limit(5)
  end

  def instance_options
    if data_type == :clicks
      {
        conversion_counts: query_conversion_counts(@affiliate_stats),
        countries: query_countries(@affiliate_stats),
      }
    else
      {
        countries: query_countries(@affiliate_stats),
        conversion_steps: query_conversion_steps(@affiliate_stats),
        approvals_from_orders: query_approvals_from_orders(@affiliate_stats),
        each_serializer: Affiliates::AffiliateStatSerializer,
        full_scope: true,
      }
    end
  end
end
