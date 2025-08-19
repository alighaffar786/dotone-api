class Api::Client::Teams::AffiliateStatsController < Api::Client::Teams::BaseController
  include Api::Client::AffiliateStatsHelper

  load_and_authorize_resource only: [:calculate, :update, :create, :conversions]

  def index
    authorize! :read, AffiliateStat
    @affiliate_stats = paginate(query_index)
    respond_with_pagination @affiliate_stats, **instance_options.merge(
      meta: { search_key: params[:search_key], search_params: search_params }
    )
  end

  def create
    if @affiliate_stat.save
      respond_with @affiliate_stat
    else
      respond_with @affiliate_stat, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_stat.update(affiliate_stat_params)
      respond_with @affiliate_stat
    else
      respond_with @affiliate_stat, status: :unprocessable_entity
    end
  end

  def show
    @affiliate_stat = AffiliateStat.find_by_id(params[:id])
    @affiliate_stat ||= AffiliateStat.find_by_valid_subid(params[:id])
    @affiliate_stat = @affiliate_stat.original unless !@affiliate_stat || @affiliate_stat.clicks?

    authorize! :read, AffiliateStat

    if @affiliate_stat
      authorize! :read, @affiliate_stat

      respond_with @affiliate_stat
    else
      head :not_found
    end
  end

  def bulk_update
    authorize! :update, AffiliateStat
    start_bulk_update_job(
      AffiliateStats::BulkUpdateJob,
      affiliate_stat_params,
    )
    head :ok
  end

  def fire_s2s
    authorize! :update, AffiliateStat
    start_fire_s2s_job
    head :ok
  end

  def fire_confirmed_s2s
    authorize! :update, AffiliateStat
    start_fire_s2s_job(confirmed: true)
    head :ok
  end

  def download
    @download = build_stat_download(query_index)
    authorize! :create, @download
    authorize! :download, AffiliateStat

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def import
    authorize! :import, AffiliateStat
    @upload = Upload.find(params[:upload_id])
    start_import_job
    head :ok
  end

  def calculate
    conversion_step = ConversionStep.find(calculate_params[:conversion_step_id])
    _, _,
    order_total,
    true_pay,
    affiliate_pay,
    true_share,
    affiliate_share = @affiliate_stat.calculate_payout_and_commission(
      calculate_params[:real_total],
      calculate_params[:real_true_pay],
      conversion_step.name,
      skip_existing_payout: true,  skip_existing_commission: true
    )

    respond_with({
      id: @affiliate_stat.id,
      conversion_step_id: conversion_step.id,
      order_total: order_total,
      true_pay: true_pay,
      affiliate_pay: affiliate_pay,
      true_share: true_share,
      affiliate_share: affiliate_share,
    })
  end

  def conversions
    if @affiliate_stat.clicks?
      @affiliate_stats = paginate(@affiliate_stat.copy_stats.preload(copy_order: [:conversion_steps, :affiliate_stat]))
      respond_with_pagination @affiliate_stats.order(captured_at: :desc), each_serializer: Teams::AffiliateStat::ConversionSerializer
    else
      head :not_found
    end
  end

  private

  def query_index
    collection = AffiliateStatCollection.new(current_ability, params, **current_options).collect
    preload_relations(collection)
  end

  def query_postback_stats
    calculator = DotOne::Services::PostbackStatCalculator.new(@affiliate_stats)
    calculator.calculate
  end

  def query_skip_api_refresh
    AffiliateStat
      .preload(:aff_hash)
      .where(id: @affiliate_stats.map(&:id))
      .each_with_object({}) do |affiliate_stat, result|
        result[affiliate_stat.id] = affiliate_stat.skip_api_refresh
      end
  end

  def start_fire_s2s_job(confirmed: false)
    AffiliateStats::FireS2sJob.perform_later(
      params[:ids],
      fire_s2s_force: true,
      confirmed: confirmed,
    )
  end

  def start_import_job
    AffiliateStats::ImportJob.perform_later(@upload.id, upload_type: params[:upload_type])
  end

  def instance_options
    if data_type == :clicks
      {
        conversion_counts: query_conversion_counts(@affiliate_stats),
        countries: query_countries(@affiliate_stats),
        each_serializer: Teams::AffiliateStat::IndexSerializer,
        clicks: true,
      }
    else
      {
        countries: query_countries(@affiliate_stats),
        conversion_steps: query_conversion_steps(@affiliate_stats),
        postback_stats: query_postback_stats,
        skip_api_refresh: query_skip_api_refresh,
        each_serializer: Teams::AffiliateStat::IndexSerializer,
      }
    end
  end

  def preload_relations(collection)
    collection = collection.preload(affiliate: :affiliate_application) if can?(:read, Affiliate)
    collection = collection.preload(offer: [:default_offer_variant, :name_translations]) if can?(:read, NetworkOffer)

    if data_type == :clicks
      collection = collection.preload(copy_order: :affiliate_stat)
    else
      collection = collection.preload(:network) if can?(:read, Network)
      collection = collection.preload(copy_order: [:affiliate_stat, conversion_steps: :true_currency], offer: :conversion_steps)
    end

    collection
  end

  def conversion_steps_params
    return {} if params[:affiliate_stat][:conversion_steps_attributes].blank?

    {
      conversion_steps: params[:affiliate_stat][:conversion_steps_attributes].map do |conversion_step|
        step = conversion_step.permit!

        [
          conversion_step[:name],
          step.merge(
            true_share: get_amount(step[:true_share]),
            true_pay: get_amount(step[:true_pay]),
            affiliate_share: get_amount(step[:affiliate_share]),
            affiliate_pay: get_amount(step[:affiliate_pay]),
          ).to_h.deep_symbolize_keys
        ]
      end.to_h
    }
  end

  def affiliate_stat_params
    assign_local_time_params(affiliate_stat: [:recorded_at, :captured_at, :published_at, :converted_at])

    if action_name.to_sym == :bulk_update
      assign_forex_value_params(affiliate_stat: [:true_pay, :affiliate_pay, :order_total])
    end

    forex_attributes =
      if action_name.to_sym == :bulk_update
        [forex_true_pay: [], forex_affiliate_pay: [], forex_order_total: []]
      elsif (action_name.to_sym == :update && @affiliate_stat.conversions? && @affiliate_stat.cached_offer&.single?)
        [:true_pay, :affiliate_pay, :order_total]
      end

    params[:affiliate_stat].delete(:skip_api_refresh) if cannot?(:flag, AffiliateStat)

    params
      .require(:affiliate_stat)
      .permit(
        :status, :approval, :skip_api_refresh, :clicks, :manual_notes, :offer_id, :affiliate_id,
        :subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :offer_variant_id, :adv_uniq_id, :aff_uniq_id, :conversions,
        :affiliate_share, :true_share, *forex_attributes,
        recorded_at_local: [], captured_at_local: [], published_at_local: [], converted_at_local: [],
      )
      .to_hash
      .merge(conversion_steps_params)
  end

  def calculate_params
    params.require(:affiliate_stat).permit(:conversion_step_id, :real_total, :real_true_pay)
  end

  def get_amount(value)
    value.to_f == 0 ? nil : value.to_f
  end
end
