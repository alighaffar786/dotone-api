class Api::Client::Advertisers::AffiliateStatsController < Api::Client::Advertisers::BaseController
  include Api::Client::AffiliateStatsHelper

  before_action :validate_stat_start_date

  load_and_authorize_resource except: [:pending_conversions, :pending_conversions_by_offer]

  def index
    @affiliate_stats = paginate(query_index)
    respond_with_pagination @affiliate_stats, **instance_options.merge(
      meta: { search_key: params[:search_key], search_params: search_params }
    )
  end

  def pending_conversions
    authorize! :read, Stat
    @stats = query_pending.preload(:offer)
    respond_with @stats, each_serializer: Advertisers::StatPendingSerializer
  end

  def query_pending
    report = DotOne::Reports::ConversionAgings.new(current_user, time_zone: current_time_zone)
    report.generate
  end

  def pending_conversions_by_offer
    @network_offer = NetworkOffer.find(params[:offer_id])
    authorize! :read, @network_offer

    report = DotOne::Reports::ConversionAgings.new(
      current_user,
      time_zone: current_time_zone,
      age_first: params[:age_first],
      age_last: params[:age_last],
    )
    respond_with report.generate_by_offer(@network_offer)
  end

  def bulk_update
    authorize! :update, AffiliateStat
    start_bulk_update_job(
      AffiliateStats::BulkUpdateJob,
      affiliate_stat_params,
    )
    head :ok
  end

  def download
    @download = build_stat_download(query_index)
    authorize! :create, @download

    if @download.save
      start_download_job(@download)
      respond_with @download, status: :ok
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def recent
    authorize! :read, AffiliateStat
    @affiliate_stats = query_recent
    respond_with(
      @affiliate_stats,
      conversion_steps: query_conversion_steps(@affiliate_stats),
      each_serializer: Advertisers::AffiliateStat::RecentSerializer,
    )
  end

  private

  def query_index
    AffiliateStatCollection.new(current_ability, params, **current_options)
      .collect
      .preload(offer: [:name_translations, :default_offer_variant], copy_order: [:affiliate_stat, :offer, :conversion_steps, :copy_stat])
  end

  def instance_options
    if data_type == :clicks
      {
        countries: query_countries(@affiliate_stats),
      }
    else
      {
        countries: query_countries(@affiliate_stats),
        conversion_steps: query_conversion_steps(@affiliate_stats),
        each_serializer: Advertisers::AffiliateStatSerializer,
      }
    end
  end

  def affiliate_stat_params
    params.require(:affiliate_stat).permit(:approval)
  end

  def query_recent
    date_range = current_time_zone.local_range(:last_30_days)
    recent_params = params.merge(start_date: date_range[0], end_date: date_range[1])

    AffiliateStatCollection.new(current_ability, recent_params, **current_options)
      .collect
      .non_invalid
      .non_rejected
      .preload(copy_order: :affiliate_stat, offer: :name_translations)
      .limit(5)
  end
end
