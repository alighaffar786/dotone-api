class Api::Client::Affiliates::TextCreativesController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: [:recent, :search]

  def index
    @text_creatives = paginate(query_index)
    respond_with_pagination @text_creatives, full_scope: full_scope?
  end

  def recent
    authorize! :read, TextCreative
    @full_scope = true
    @text_creatives = query_index.limit(10)
    respond_with @text_creatives, full_scope: full_scope?
  end

  def search
    authorize! :read, TextCreative
    @text_creatives = query_search
    respond_with @text_creatives, each_serializer: Affiliates::TextCreative::SearchSerializer
  end

  private

  def query_index
    collection = TextCreativeCollection.new(current_ability, params).collect

    if full_scope?
      collection
        .select_approval_status(current_user)
        .agg_affiliate_pay(current_user, current_currency_code)
        .preload(:image, :offer_variant, :categories, :currency)
        .preload(offer: [:default_offer_variant, :aff_hash, :name_translations, :offer_name_translations, :brand_image])
    else
      collection.preload(:image, :currency, offer: :aff_hash)
    end
  end

  def query_search
    TextCreativeCollection.new(current_ability, params.except(:locale))
      .collect
      .preload(:image, :category_groups, categories: :category_group)
      .preload(offer: [:aff_hash, :name_translations, :offer_name_translations, :brand_image])
  end
end
