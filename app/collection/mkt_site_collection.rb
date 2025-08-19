class MktSiteCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_verified if params.key?(:verified)
  end

  def filter_by_affiliate_ids
    filter do
      @relation.with_affiliates(params[:affiliate_ids])
    end
  end

  def filter_by_network_ids
    filter do
      @relation.with_networks(params[:network_ids])
    end
  end

  def filter_by_offer_ids
    filter do
      @relation.with_offers(params[:offer_ids])
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end

  def filter_by_search
    filter { @relation.like(params[:search]) }
  end

  def filter_by_verified
    filter { @relation.where(verified: params[:verified]) }
  end

  def sort_by_last_used_at
    sort do
      @relation
        .left_joins(offer: :js_conversion_pixel)
        .order("offer_conversion_pixels.updated_at #{sort_order}")
    end
  end
end
