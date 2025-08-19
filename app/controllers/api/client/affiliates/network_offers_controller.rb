class Api::Client::Affiliates::NetworkOffersController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource only: [:index, :show]
  load_resource :affiliate_tag, find_by: :name, id_param: :tag_name, only: :by_tag

  after_action :record_search, only: :index

  def index
    @network_offers = query_index

    respond_with_pagination paginate(@network_offers), each_serializer: each_serializer do |current|
      format_index(current)
    end
  end

  def top_offers
    authorize! :read, NetworkOffer
    @network_offers = query_top_offers
    respond_with @network_offers, each_serializer: each_serializer
  end

  def search
    authorize! :read, NetworkOffer
    @network_offers = query_search
    respond_with @network_offers, each_serializer: each_serializer
  end

  def by_tag
    authorize! :read, NetworkOffer
    @network_offers = query_by_tag
    respond_with @network_offers, each_serializer: each_serializer, image_size: params[:image_size]
  end

  def show
    respond_with @network_offer, serializer: Affiliates::NetworkOfferSerializer
  end

  def similar
    @network_offer = NetworkOffer.find(params[:id])
    authorize! :read, @network_offer
    respond_with query_similar, each_serializer: each_serializer, image_size: :small
  end

  private

  def query_index
    NetworkOfferCollection.new(current_ability, params, **current_options).collect
  end

  def query_top_offers
    NetworkOfferCollection.new(current_ability, params, **current_options)
      .collect
      .select(:id, :name, :affiliate_conv_type, :custom_epc, :published_date)
      .select_translations(:manager_insight, current_locale)
      .preload(:brand_image_medium, :top_traffic_sources)
      .agg_affiliate_pay(current_user, current_currency_code)
      .limit(params[:limit])
  end

  def query_search
    NetworkOfferCollection.new(current_ability, params, **current_options).search
  end

  def query_by_tag
    return [] unless @affiliate_tag

    NetworkOfferCollection.new(current_ability, params.merge(all_locale: true), **current_options)
      .collect
      .where(id: @affiliate_tag.offers.select(:id))
      .select(:id)
      .select_translations(:name, current_locale)
      .preload(:brand_image_small, :brand_image_large, default_conversion_step: :label_translations)
      .agg_affiliate_pay(current_user, current_currency_code)
  end

  def query_similar
    NetworkOfferCollection.new(current_ability, params.merge(all_locale: true), **current_options)
      .collect
      .where(id: @network_offer.similar_offers.accessible_by(current_ability).pluck(:id).sample(5))
      .select(:id)
      .select_translations(:name, current_locale)
      .preload(:brand_image_small, :brand_image_large, default_conversion_step: :label_translations)
      .agg_affiliate_pay(current_user, current_currency_code)
  end

  def format_index(current)
    current
      .select(
        :id, :name, :earning_meter, :affiliate_conv_type, :approval_method, :approved_time, :need_approval,
        :approved_time_num_days, :published_date, :cache_days_to_expire
      )
      .select_approval_status(current_user)
      .preload(:brand_image_small, :categories, :countries, :default_offer_variant, :media_restrictions, :aff_hash)
      .preload(default_conversion_step: :label_translations)
      .preload_translations(:name, :short_description, :approval_message)
      .agg_affiliate_pay(current_user, current_currency_code)
  end

  def record_search
    return if current_search.blank? || current_page.to_i > 1

    AffiliateSearchLog.record_offer_search!(
      affiliate_id: current_user.id,
      offer_keyword: current_search.squish,
      date: Time.now.utc.to_date,
    )
  end

  def each_serializer
    case action_name.to_sym
    when :index
      Affiliates::NetworkOffer::IndexSerializer
    when :top_offers
      Affiliates::NetworkOffer::TopOfferSerializer
    when :search
      Affiliates::NetworkOffer::SearchSerializer
    when :by_tag, :similar
      Affiliates::NetworkOffer::FeaturedSerializer
    end
  end
end
