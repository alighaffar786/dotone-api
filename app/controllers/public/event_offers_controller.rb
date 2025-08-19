class Public::EventOffersController < Public::BaseController
  def index
    @event_offers = query_index
    render json: @event_offers
  end

  private

  def query_index
    EventOffer
      .joins(:event_info, :default_offer_variant)
      .preload(
        :name_translations, { default_conversion_step: :true_currency },
        event_info: [:images, :category_groups, :media_category],
      )
        .is_not_private_event
      .where(offer_variants: { status: OfferVariant.status_considered_public })
      .where('offers.published_date IS NOT NULL')
      .order('offers.published_date DESC, offers.id DESC')
      .distinct
      .paginate(page: current_page, per_page: current_per_page)
  end
end
