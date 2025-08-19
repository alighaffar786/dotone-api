class Api::Client::Affiliates::Reports::StatSummariesController < Api::Client::Affiliates::BaseController
  include Api::StatSummaryHelper

  before_action :validate_stat_start_date

  def stat_summary_klass
    DotOne::Reports::Affiliates::StatSummary
  end

  def index
    authorize! :read, Stat
    @stats, @total = query_stat_summary
    @stats = array_paginate(@stats)
    respond_with_pagination @stats, **instance_options, meta: { total: @total }
  end

  def download
    @download = build_download(query_download, current_columns, currency_code: current_currency_code)
    @download.name = params[:download_title]

    authorize! :create, @download
    authorize! :read, Stat

    if @download.save
      start_download_job(@download, formatters: :download_summary_formatters)
      respond_with @download, status: :ok
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def instance_options
    super.merge(each_serializer: Affiliates::StatSummarySerializer)
  end

  def query_download
    report = DotOne::Reports::Affiliates::StatSummary.new(current_ability, report_params)
    stats = report.generate
    stats = stats.preload(offer: :name_translations) if current_columns.include?(:offer_id)
    stats
  end

  def report_params
    params
      .permit(
        *DotOne::Reports::Affiliates::StatSummary.dimensions,
        :billing_region, :date_type, :period, :start_date, :end_date, :sort_field, :sort_order, :offer_ids, :offer_variant_ids,
        :text_creative_ids, :image_creative_ids, :ad_slot_ids, :columns_required,
        offer_ids: [], offer_variant_ids: [], text_creative_ids: [], image_creative_ids: [], ad_slot_ids: [],
        columns_required: []
      )
      .merge(super)
  end
end
