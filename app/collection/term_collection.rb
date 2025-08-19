class TermCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_distinct
    filter_by_event_offers if params[:event_offer_ids].present?
  end

  def filter_by_event_offers
    filter do
      @relation.joins(:event_offers).where(event_offers: { id: params[:event_offer_ids] })
    end
  end

  def filter_by_search
    filter { @relation.like(params[:search]) }
  end
end
