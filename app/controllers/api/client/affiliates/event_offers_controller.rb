class Api::Client::Affiliates::EventOffersController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: [:recent, :personalized]

  def index
    @event_offers = paginate(query_index)
    respond_with_pagination @event_offers, each_serializer: Affiliates::EventOffer::IndexSerializer do |current|
      format_index(current)
    end
  end

  def personalized
    authorize! :read, EventOffer
    @event_offers = paginate(query_personalized)
    respond_with_pagination @event_offers, each_serializer: Affiliates::EventOffer::IndexSerializer do |current|
      format_index(current)
    end
  end

  def recent
    authorize! :read, EventOffer
    @event_offers = query_recent
    respond_with @event_offers, each_serializer: Affiliates::EventOffer::RecentSerializer
  end

  def show
    respond_with @event_offer, serializer: Affiliates::EventOfferSerializer
  end

  private

  def query_personalized
    EventOfferCollection.new(current_ability, personalized_params, **current_options).collect
  end

  def query_index
    EventOfferCollection.new(current_ability, params, **current_options).collect
  end

  def query_recent
    ids = EventOffer.accessible_by(current_ability)
      .order(published_date: :desc)
      .select(:id, :network_id, :published_date)
      .uniq(&:network_id)

    query_index
      .where(id: ids)
      .preload(:brand_image, default_conversion_step: :true_currency, event_info: :media_category)
      .limit(6)
  end

  def format_index(current)
    current
      .select_approval_status(current_user)
      .select_forex_total(current_currency_code)
      .preload(:brand_image, :categories, :countries, default_conversion_step: :true_currency, event_info: [:brand_image, :media_category, :event_media_category])
      .preload_translations(:name, :short_description)
  end

  def personalized_params
    params.merge(personalized: true, private: false)
  end
end
