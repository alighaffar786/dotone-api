class Api::Client::Teams::TextCreativesController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @text_creatives = paginate(query_index)
    respond_with_pagination @text_creatives
  end

  def create
    if @text_creative.save
      respond_with @text_creative.reload
    else
      respond_with @text_creative, status: :unprocessable_entity
    end
  end

  def update
    if @text_creative.update(text_creative_params)
      respond_with @text_creative.reload
    else
      respond_with @text_creative, status: :unprocessable_entity
    end
  end

  def destroy
    if @text_creative.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def bulk_update
    authorize! :update, TextCreative
    start_bulk_update_job(
      TextCreatives::BulkUpdateJob,
      text_creative_bulk_update_params,
    )
    head :ok
  end

  private

  def query_index
    collection = TextCreativeCollection.new(@text_creatives, params).collect
    collection.preload(
      :offer_variant, :creative, :categories, :text_creative_categories, :image, :currency, :network,
      categories: [:category_group],
      offer: [:aff_hash, :default_offer_variant, :offer_name_translations, :name_translations, :brand_image]
    )
  end

  def text_creative_params
    if (offer_variant_id = params[:text_creative]&.delete(:offer_variant_id))
      params[:text_creative][:offer_variant_ids] = [offer_variant_id]
    end

    assign_local_time_params(text_creative: [:active_date_end, :active_date_start, :published_at])

    params.require(:text_creative).permit(
      :status, :status_reason, :is_infinity_time, :button_text, :deal_scope, :coupon_code, :currency_id, :title,
      :creative_name, :content_1, :original_price, :discount_price, :locales, :client_url, :image_cdn,
      offer_variant_ids: [], locales: [], published_at_local: [], active_date_start_local: [], active_date_end_local: [],
      category_ids: []
    )
  end

  def text_creative_bulk_update_params
    params.require(:text_creative).reject! { |_, value| value.to_s.blank? }

    text_creative_params
      .permit(:status, :status_reason, :is_infinity_time, active_date_start_local: [], active_date_end_local: [])
      .tap do |param|
        param.delete(:is_infinity_time) if falsy?(param[:is_infinity_time]) && param[:active_date_start_local].nil? && param[:active_date_end_local].nil?
      end
      .to_h
  end
end
