class Api::Client::Affiliates::ProductsController < Api::Client::Affiliates::BaseController
  after_action :record_search

  def search
    authorize! :read, Product
    @products = array_paginate(query_index)
    respond_with_pagination @products, offers_map: offers_map, meta: { offer_filters: generate_offer_filters }
  end

  def quick_search
    authorize! :read, Product
    @products = query_quick_search
    respond_with @products, each_serializer: Affiliates::Product::SearchSerializer
  end

  private

  def query_index
    collection = ProductCollection.new(
      search_results,
      params,
      offers_map: offers_map,
      **current_options,
    )
    @offers_map = collection.offers_map
    collection.collect
  end

  def query_quick_search
    collection = Product.es_search(current_search, limit: 100)
    offer_ids = NetworkOffer.accessible_by(current_ability).where(id: collection.map(&:offer_id)).pluck(:id)

    collection
      .select { |product| offer_ids.include?(product.offer_id) }
      .take(10)
  end

  def search_results
    @search_results ||= fetch_cached(Product, current_search) do
      Product
        .es_search(current_search, raw: true, size: 1000)
        .map { |product| Product.initialize_safely(product[:_source]) }
    end
  end

  def offers_map
    @offers_map ||= begin
      offer_ids = search_results.map(&:offer_id).uniq

      fetch_cached(Offer, offer_ids) do
        NetworkOffer.accessible_by(current_ability)
          .where(id: offer_ids)
          .preload(:default_offer_variant, :name_translations)
          .agg_affiliate_pay(current_user, current_currency_code)
          .index_by(&:id)
      end
    end
  end

  def generate_offer_filters
    search_results
      .group_by(&:offer_id)
      .transform_values(&:count)
      .map do |offer_id, total_products|
        next unless offer = offers_map[offer_id]

        {
          id: offer.id,
          name: offer.t_name,
          total_products: total_products,
        }
      end
      .compact
      .sort_by { |offer| offer[:name] }
  end

  def record_search
    return if current_search.blank? || current_page > 1

    AffiliateSearchLog.record_product_search!(
      affiliate_id: current_user.id,
      product_keyword: current_search,
      date: Time.now.utc.to_date,
    )
  end
end
