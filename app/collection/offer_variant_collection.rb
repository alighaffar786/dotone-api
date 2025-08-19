class OfferVariantCollection < BaseCollection
  private

  def ensure_filters
    super

    filter_by_offer_type
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_is_default if truthy?(params[:is_default]) || falsy?(params[:is_default])
    filter_by_statuses if params[:statuses].present?
    filter_non_suspended if truthy?(params[:exclude_suspended])
  end

  def filter_by_offer_type
    filter { @relation.joins(:offer).where(offers: { type: params[:offer_type] || 'NetworkOffer' }) }
  end

  def filter_by_offer_ids
    filter { @relation.where(offer_id: params[:offer_ids]) }
  end

  def filter_by_is_default
    filter { @relation.where(is_default: params[:is_default]) }
  end

  def filter_by_statuses
    filter { @relation.where(status: params[:statuses]) }
  end

  def filter_non_suspended
    filter { @relation.not_suspended }
  end

  def default_sorted
    sort { @relation.order(offer_id: :desc, is_default: :desc).order_by_status.order(created_at: :desc) }
  end
end
