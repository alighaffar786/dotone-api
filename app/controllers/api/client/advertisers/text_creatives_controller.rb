class Api::Client::Advertisers::TextCreativesController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @text_creatives = paginate(query_index)
    respond_with_pagination @text_creatives
  end

  def create
    if @text_creative.save
      @text_creative.category_ids = text_creative_category_ids.concat(@text_creative.category_ids).take(5)
      # Temporary: Will be removed after offer_variant db design is modified
      respond_with @text_creative.reload
    else
      respond_with @text_creative, status: :unprocessable_entity
    end
  end

  def update
    if @text_creative.update(text_creative_update_params)
      respond_with @text_creative.reload
    else
      respond_with @text_creative, status: :unprocessable_entity
    end
  end

  def update_bulk
    authorize! :update, TextCreative
    @text_creatives = query_updatable
    @text_creatives.update(text_creative_update_params)

    if @text_creatives.all?(&:valid?)
      respond_with @text_creatives
    else
      respond_with @text_creatives.select(&:invalid?).first, status: :unprocessable_entity
    end
  end

  private

  def query_updatable
    TextCreative
      .accessible_by(current_ability)
      .preload(
        :offer_variant, :creative, :categories, :text_creative_categories, :image,
        offer: [
          :aff_hash, :offer_name_translations, :name_translations,
          ordered_conversion_steps: [:true_currency, :label_translations]
        ]
      )
      .where(text_creatives: { id: params[:ids] })
  end

  def query_index
    TextCreativeCollection.new(@text_creatives, params)
      .collect
      .preload(
        :offer_variant, :creative, :categories, :text_creative_categories, :image, :currency,
        offer: [:aff_hash, :offer_name_translations, :name_translations, :default_offer_variant]
      )
  end

  def text_creative_original_params
    if params[:text_creative] && params[:text_creative][:offer_variant_id]
      params[:text_creative][:offer_variant_ids] = [params[:text_creative].delete(:offer_variant_id)]
    end

    assign_local_time_params(text_creative: [:active_date_end, :active_date_start, :published_at])

    params.require(:text_creative).permit(
      :status, :button_text, :deal_scope, :coupon_code, :currency_id, :title, :creative_name, :content_1,
      :original_price, :discount_price, :locales, :client_url, :image_cdn, :is_infinity_time,
      offer_variant_ids: [], locales: [], active_date_start_local: [], active_date_end_local: [], published_at_local: []
    )
  end

  def text_creative_params
    text_creative_original_params.delete_if do |key, value|
      key == 'status' && value != TextCreative.status_paused
    end
  end

  def text_creative_update_params
    text_creative_original_params.merge(
      category_ids: text_creative_category_ids,
    ).tap do |param|
      param[:status] = TextCreative.status_pending unless TextCreative.statuses(:network).include?(param[:status])
    end
  end

  def text_creative_category_ids
    params.dig(:text_creative, :category_ids) || []
  end
end
