class Api::Client::Teams::Reports::StatSummariesController < Api::Client::Teams::BaseController
  include Api::StatSummaryHelper

  def stat_summary_klass
    DotOne::Reports::AffiliateUsers::StatSummary
  end

  def index
    authorize! :read, Stat
    @stats, @total = query_stat_summary
    @stats = array_paginate(@stats)
    respond_with_pagination @stats, **instance_options, meta: { total: @total }
  end

  def top_performers
    authorize! :read, Stat
    @stats = fetch_cached_on_controller(current_columns, expires_in: 30.minutes) { query_top_performers.to_a }
    respond_with @stats, **instance_options
  end

  def delta_summary
    authorize! :read, Stat

    load_delta = -> { paginate(query_delta_summaries).to_a }

    @stats =
      if truthy?(params[:dashboard])
        fetch_cached_on_controller(*delta_summary_cache_keys, expires_in: 30.minutes) { load_delta.call }
      else
        load_delta.call
      end

    respond_with_pagination @stats, **delta_summary_instance_options
  end

  def overview
    authorize! :read, Stat

    if current_user.upper_team?
      @stats = fetch_cached_on_controller(expires_in: 30.minutes) { query_overview }
      respond_with @stats
    else
      head :unauthorized
    end
  end

  def download
    @download = build_download(query_download, current_columns, currency_code: current_currency_code)
    @download.name = params[:download_title]

    authorize! :create, @download
    authorize! :download, Stat

    if @download.save
      start_download_job(@download, formatters: :download_summary_formatters)
      respond_with @download, status: :ok
    else
      respond_with @download, status: :unprocessable_entity
    end
  end


  private

  def instance_options
    super.merge(each_serializer: Teams::StatSummarySerializer)
  end

  def delta_summary_instance_options
    load_delta_options = -> {
      options = { each_serializer: Teams::Stat::DeltaSummarySerializer }

      case params[:dimension]&.to_sym
      when :offer_id
        options[:offers] = NetworkOffer.where(id: @stats.map(&:offer_id)).preload(:name_translations).index_by(&:id)
      when :affiliate_id
        options[:affiliates] = Affiliate.where(id: @stats.map(&:affiliate_id)).preload(:affiliate_application).index_by(&:id)
      end

      options
    }

    if truthy?(params[:dashboard])
      fetch_cached_on_controller(*delta_summary_cache_keys, 'delta_summary_instance_options', expires_in: 30.minutes) { load_delta_options.call }
    else
      load_delta_options.call
    end
  end

  def query_top_performers
    report = stat_summary_klass.new(current_ability, top_performer_params)
    report.generate_top_perfomers
  end

  def query_delta_summaries
    Stat.payout_delta(delta_summary_params.to_h)
  end

  def query_overview
    report = stat_summary_klass.new(current_ability, current_options.merge(billing_region: params[:billing_region]))
    report.generate_overview
  end

  def query_download
    report = stat_summary_klass.new(current_ability, report_params)
    report.generate
  end

  def top_performer_params
    {
      currency_code: current_currency_code,
      time_zone: current_time_zone,
      columns: current_columns,
    }
  end

  def delta_summary_params
    params
      .permit(:sort_order, :period, :dimension, :sort_field)
      .merge(user: current_user, currency_code: current_currency_code, time_zone: current_time_zone)
  end

  def delta_summary_cache_keys
    delta_summary_params.except(:user, :currency_code, :time_zone).values
  end

  def report_params
    params
      .permit(
        *DotOne::Reports::AffiliateUsers::StatSummary.dimensions,
        :billing_region, :date_type, :period, :start_date, :end_date, :sort_field, :sort_order, :offer_ids, :offer_variant_ids,
        :text_creative_ids, :image_creative_ids, :ad_slot_ids, :columns_required, :affiliate_ids, :network_ids,
        :affiliate_user_ids, :recruiter_ids, :country_ids, :excluded_offer_ids, :excluded_affiliate_ids, :excluded_network_ids,
        offer_ids: [], offer_variant_ids: [], text_creative_ids: [], image_creative_ids: [], ad_slot_ids: [],
        columns_required: [], affiliate_ids: [], network_ids: [], affiliate_user_ids: [], recruiter_ids: [], country_ids: [],
        excluded_offer_ids: [], excluded_affiliate_ids: [], excluded_network_ids: [],
      )
      .merge(super)
  end
end
