class EventAffiliateOfferCollection < AffiliateOfferCollection
  def self.model
    AffiliateOffer
  end

  private

  def ensure_filters
    super
    filter_by_event_offer_ids if params[:event_offer_ids].present?
    filter_by_event_statuses if params[:event_statuses].present?
  end

  def filter_by_type
    filter { @relation.joins(:event_offer)}
  end

  def filter_by_event_offer_ids
    filter { @relation.where(offer_id: params[:event_offer_ids]) }
  end

  def filter_by_event_statuses
    filter do
      @relation
        .joins(:default_offer_variant)
        .where(offer_variants: { status: params[:event_statuses] })
    end
  end
end
