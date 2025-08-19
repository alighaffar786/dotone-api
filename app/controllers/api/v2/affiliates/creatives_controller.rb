class Api::V2::Affiliates::CreativesController < Api::V2::Affiliates::BaseController
  load_and_authorize_resource class: TextCreative, if: :creative_type_feed?
  load_and_authorize_resource class: ImageCreative, if: :creative_type_image?

  def index
    @creatives = paginate(query_index)
    respond_with_pagination(@creatives, each_serializer: creative_serializer)
  end

  private

  def creative_type_feed?
    params[:creative_type] == 'feed'
  end

  def creative_type_image?
    params[:creative_type] == 'image'
  end

  def creative_serializer
    if creative_type_feed?
      V2::Affiliates::TextCreativeSerializer
    elsif creative_type_image?
      V2::Affiliates::ImageCreativeSerializer
    end
  end

  def require_params
    params.require(:offer_id) if params[:offer_variant_id].blank?
    params.require(:offer_variant_id) if params[:offer_id].blank?
    params.delete(:creative_type) unless ['feed', 'image'].include?(params[:creative_type])
    params.require(:creative_type)
  end

  def query_index
    params[:offer_ids] = params.delete(:offer_id)
    params[:offer_variant_ids] = params.delete(:offer_variant_id)
    params.merge!(with_active_affiliate_offers: true)

    klass = creative_type_feed? ? TextCreativeCollection : ImageCreativeCollection
    collection = klass.new(current_ability, params)
      .collect
      .preload(offer: [:default_offer_variant, :name_translations])

    collection = collection
      .agg_affiliate_pay(current_user, current_currency_code)
      .preload(:image) if creative_type_feed?

    collection
  end
end
