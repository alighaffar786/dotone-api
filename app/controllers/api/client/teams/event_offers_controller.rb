class Api::Client::Teams::EventOffersController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    @event_offers = paginate(query_index)
    respond_with_pagination @event_offers, each_serializer: Teams::EventOffer::IndexSerializer do |current|
      format_index(current)
    end
  end

  def search
    authorize! :read, EventOffer
    @event_offers = query_search
    respond_with @event_offers, each_serializer: Teams::EventOffer::SearchSerializer
  end

  def show
    respond_with @event_offer, serializer: Teams::EventOfferSerializer,
      meta: {
        t_columns: {
          event_offer: EventOffer.dynamic_translatable_attribute_types,
          event_info: EventInfo.dynamic_translatable_attribute_types,
        },
      }
  end

  def create
    if @event_offer.save
      @event_offer.reload
      @event_offer.update(event_offer_params.to_h.deep_merge(
        event_info_attributes: { id: @event_offer.event_info.id },
        default_conversion_step_attributes: { id: @event_offer.default_conversion_step.id }
      ))
      respond_with @event_offer
    else
      respond_with @event_offer, status: :unprocessable_entity
    end
  end

  def update
    if @event_offer.update(event_offer_params)
      respond_with @event_offer, serializer: Teams::EventOfferSerializer
    else
      respond_with @event_offer, status: :unprocessable_entity
    end
  end

  def duplicate
    @copy = DotOne::Copier::EventOffer.new(@event_offer, current_user).copy
    authorize! :create_event, @copy

    if @copy.persisted?
      respond_with @copy
    else
      respond_with @copy, status: :unprocessable_entity
    end
  end

  private

  def query_index
    EventOfferCollection.new(@event_offers, params, **current_options).collect
  end

  def query_search
    EventOfferCollection.new(current_ability, params, **current_options).search
  end

  def format_index(current)
    collection = current
      .agg_request_count
      .preload(
        :brand_image, :default_offer_variant, :categories, :countries, :name_translations,
        event_info: [:translations, :event_tag, :event_media_category, related_offer: :name_translations],
        default_conversion_step: :true_currency
      )
    collection = collection.preload(:network) if can?(:read, Network)
    collection
  end

  def event_offer_params
    assign_local_time_params(event_offer: EventOffer.local_time_attributes)
    assign_local_time_params({ event_info_attributes: EventInfo.local_time_attributes }, params[:event_offer])

    params.require(:event_offer)
      .permit(
        :network_id, :name, :short_description, :brand_image_url, :email, :approval_message,
        category_ids: [], published_date_local: [], country_ids: [], term_ids: [],
        default_offer_variant_attributes: [:id, :status],
        default_conversion_step_attributes: [
          :id, :true_currency_id, :true_pay, :affiliate_pay, :max_affiliate_pay, :affiliate_pay_flexible,
        ],
        event_info_attributes: [
          :id, :is_private, :availability_type, :event_type, :related_offer_id, :coordinator_email,
          :value, :fulfillment_type, :quota, :is_supplement_needed, :is_address_needed, :is_affiliate_requirement_needed,
          :supplement_notes, :popularity, :popularity_unit, :event_media_category_id, :event_contract,
          :details, :event_requirements, :instructions, :keyword_requirements,
          images_attributes: [:id, :cdn_url, :_destroy],
          applied_by_local: [], category_group_ids: [], selection_by_local: [], submission_by_local: [],
          evaluation_by_local: [], published_by_local: [],
          translations_attributes: [:id, :locale, :field, :content]
        ],
        translations_attributes: [:id, :locale, :field, :content]
      )
  end
end
