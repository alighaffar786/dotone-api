class Api::V2::Affiliates::NetworkOffersController < Api::V2::Affiliates::BaseController
  load_and_authorize_resource

  def index
    @network_offers = paginate(query_index)
    respond_with_pagination @network_offers, each_serializer: each_serializer, affiliate_offers: query_affiliate_offers
  end

  private

  def query_index
    collection = NetworkOfferCollection.new(current_ability, params, **current_options).collect
    collection = collection.preload(:name_translations)
    unless mini?
      collection = collection.preload(
        :short_description_translations, :target_audience_translations, :suggested_media_translations,
        :other_info_translations, :approval_message_translations, :offer_categories, :categories,
        :offer_countries, :countries, :owner_has_tags, :media_restrictions, :offer_cap,
        ordered_conversion_steps: [step_prices: :true_currency],
        offer_variants: [:name_translations, :description_translations],
      )
    end
    collection
  end

  def each_serializer
    if truthy?(params[:mini])
      V2::Affiliates::NetworkOffer::MiniSerializer
    else
      V2::Affiliates::NetworkOfferSerializer
    end
  end

  def mini?
    truthy?(params[:mini])
  end

  def query_affiliate_offers
    return {} if mini?

    args = { affiliate_ids: current_user.id, offer_ids: @network_offers.ids }
    AffiliateOfferCollection.new(current_ability, args).collect.index_by(&:offer_id)
  end
end
