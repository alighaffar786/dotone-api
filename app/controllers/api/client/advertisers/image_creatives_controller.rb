class Api::Client::Advertisers::ImageCreativesController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @image_creatives = paginate(query_index)
    respond_with_pagination @image_creatives, download_counts: query_download_counts
  end

  def create
    if @image_creative.save
      respond_with @image_creative.reload
    else
      respond_with @image_creative, status: :unprocessable_entity
    end
  end

  def update
    if @image_creative.update(image_creative_update_params)
      respond_with @image_creative.reload
    else
      respond_with @image_creative, status: :unprocessable_entity
    end
  end

  def update_bulk
    authorize! :update, ImageCreative
    @image_creatives = query_updatable
    @image_creatives.update(image_creative_update_params)

    if @image_creatives.all?(&:valid?)
      respond_with @image_creatives
    else
      respond_with @image_creatives.select(&:invalid?).first, status: :unprocessable_entity
    end
  end

  private

  def query_updatable
    ImageCreative
      .accessible_by(current_ability)
      .preload(:creative, :offer_variant, :creatives, :offer_variants, :offer)
      .where(image_creatives: { id: params[:ids] })
  end

  def query_index
    collection = ImageCreativeCollection.new(@image_creatives, params).collect
    collection.preload(
      :offer_variant, offer: [:name_translations, :default_offer_variant, ordered_conversion_steps: [:active_pay_schedule, :label_translations, :true_currency]]
    )
  end

  def image_creative_params
    assign_local_time_params(image_creative: [:active_date_start, :active_date_end])

    params.require(:image_creative).permit(
      :offer_variant_id, :is_infinity_time, :status_reason, :status, :client_url, :width, :height, :cdn_url, :locales,
      active_date_start_local: [], active_date_end_local: [], locales: []
    )
  end

  def image_creative_update_params
    image_creative_params.tap do |param|
      param[:status] = ImageCreative.status_pending unless ImageCreative.statuses(:network).include?(param[:status])
    end
  end

  def query_download_counts
    DotOne::Reports::ImageCreativeDownloadStat.new(
      image_creative_ids: @image_creatives.map(&:id),
    ).generate(view_count_only: true)
  end
end
