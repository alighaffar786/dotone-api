class Api::Client::Advertisers::Reports::StatSummariesController < Api::Client::Advertisers::BaseController
  before_action :validate_stat_start_date

  def index
    authorize! :read, Stat
    @stats, @total = query_index
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

  def query_index
    report = DotOne::Reports::Networks::StatSummary.new(current_ability, report_params)
    [report.generate, report.total]
  end

  def query_download
    report = DotOne::Reports::Networks::StatSummary.new(current_ability, report_params)
    stats = report.generate
    stats = stats.preload(offer: :name_translations) if current_columns.include?(:offer_id)
    stats
  end

  def instance_options
    {
      each_serializer: Advertisers::StatSummarySerializer,
      columns: current_columns,
      offers: offers,
      image_creatives: image_creatives,
      text_creatives: text_creatives,
    }
  end

  def offers
    return {} unless current_columns.include?(:offer_id)

    NetworkOffer
      .where(id: @stats.map(&:offer_id))
      .preload(:name_translations, ordered_conversion_steps: [:true_currency, :label_translations])
      .index_by(&:id)
  end

  def image_creatives
    return {} unless current_columns.include?(:image_creative_id)

    ImageCreative
      .where(id: @stats.map(&:image_creative_id))
      .index_by(&:id)
  end

  def text_creatives
    return {} unless current_columns.include?(:text_creative_id)

    TextCreative
      .where(id: @stats.map(&:text_creative_id))
      .index_by(&:id)
  end

  def report_params
    params
      .permit(
        :date_type, :end_date, :start_date, :period, :sort_field, :sort_order, :affiliate_ids, :media_category_ids,
        :dimension, :offer_ids, :image_creative_ids, :text_creative_ids, affiliate_ids: [], media_category_ids: [],
        offer_ids: [], image_creative_ids: [], text_creative_ids: [], columns: []
      )
      .merge(currency_code: current_currency_code, time_zone: current_time_zone, columns: current_columns)
  end
end
