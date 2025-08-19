class Api::Client::Teams::OfferVariantsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: [:search, :test_urls]

  def index
    @offer_variants = paginate(query_index)
    respond_with_pagination @offer_variants, meta: { t_columns: OfferVariant.dynamic_translatable_attribute_types }
  end

  def search
    authorize! :read, OfferVariant
    @offer_variants = query_search
    respond_with @offer_variants, each_serializer: Teams::OfferVariant::SearchSerializer
  end

  def create
    if @offer_variant.save
      respond_with @offer_variant
    else
      respond_with @offer_variant, status: :unprocessable_entity
    end
  end

  def update
    if @offer_variant.update(offer_variant_params)
      respond_with @offer_variant, siblings: { @offer_variant.id => @offer_variant.siblings}
    else
      respond_with @offer_variant, status: :unprocessable_entity
    end
  end

  def test_urls
    authorize! :read, OfferVariant
    @offer_variants = paginate(query_test_urls)
    respond_with_pagination @offer_variants, each_serializer: Teams::OfferVariant::TestUrlSerializer
  end

  private

  def query_index
    collection = OfferVariantCollection.new(@offer_variants, params).collect
    collection
      .preload_translations(:name, :description)
      .preload(:network, offer: :name_translations)
  end

  def query_search
    collection = OfferVariantCollection.new(current_ability, params).collect.preload(:offer).order(is_default: :desc)
    collection.preload(:name_translations)
  end

  def query_test_urls
    collection = OfferVariantCollection.new(current_ability, { offer_ids: params[:offer_id], exclude_suspended: true }).collect
    collection = collection.preload(:name_translations)
    collection
  end

  def offer_variant_params
    params
      .require(:offer_variant)
      .permit(
        :offer_id, :name, :is_default, :status, :description, :destination_url, :variant_type,
        translations_attributes: [:id, :locale, :field, :content]
      )
  end
end
