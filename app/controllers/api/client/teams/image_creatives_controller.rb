class Api::Client::Teams::ImageCreativesController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    @image_creatives = paginate(query_index)
    respond_with_pagination @image_creatives, download_counts: query_download_counts
  end

  def search
    authorize! :read, ImageCreative
    @image_creatives = query_search
    respond_with @image_creatives, each_serializer: Teams::ImageCreative::SearchSerializer
  end

  def create
    if @image_creative.save
      respond_with @image_creative.reload
    else
      respond_with @image_creative, status: :unprocessable_entity
    end
  end

  def update
    if @image_creative.update(image_creative_params)
      if @image_creative.rejected? && @image_creative.status_previously_changed?
        ImageCreative.send_rejected_notification(@image_creative)
      end

      respond_with @image_creative
    else
      respond_with @image_creative, status: :unprocessable_entity
    end
  end

  def bulk_update
    authorize! :update, ImageCreative
    start_bulk_update_job(
      ImageCreatives::BulkUpdateJob,
      image_creative_bulk_update_params,
    )
    head :ok
  end

  def destroy
    if @image_creative.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    collection = ImageCreativeCollection.new(@image_creatives, params).collect
    collection.preload(:network, :offer_variant, offer: [:default_offer_variant, :group_tags, :name_translations])
  end

  def query_search
    ImageCreativeCollection.new(current_ability, params).collect
  end

  def query_download_counts
    report = DotOne::Reports::ImageCreativeDownloadStat.new(image_creative_ids: @image_creatives.map(&:id))
    report.generate(view_count_only: true)
  end

  def image_creative_params
    assign_local_time_params(image_creative: [:active_date_start, :active_date_end])

    params.require(:image_creative).permit(
      :internal, :offer_variant_id, :locales, :status, :client_url, :status_reason, :width, :height, :cdn_url, :is_infinity_time,
      active_date_start_local: [], active_date_end_local: [], locales: []
    )
  end

  def image_creative_bulk_update_params
    params.require(:image_creative).reject! { |_, value| value.to_s.blank? }

    image_creative_params
      .permit(:status, :status_reason, :is_infinity_time, active_date_start_local: [], active_date_end_local: [])
      .tap do |param|
        param.delete(:is_infinity_time) if falsy?(param[:is_infinity_time]) && param[:active_date_start_local].nil? && param[:active_date_end_local].nil?
      end
      .to_h
  end
end
