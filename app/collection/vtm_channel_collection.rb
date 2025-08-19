class VtmChannelCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_mkt_site_ids if params[:mkt_site_ids].present?
  end

  def filter_by_mkt_site_ids
    filter do
      @relation.where(mkt_site_id: params[:mkt_site_ids])
    end
  end

  def filter_by_offer_ids
    filter { @relation.where(offer_id: params[:offer_ids]) }
  end

  def filter_by_network_ids
    filter { @relation.where(network_id: params[:network_ids]) }
  end
end
