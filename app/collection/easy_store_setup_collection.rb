class EasyStoreSetupCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_network_ids if params[:network_ids].present?
    filter_by_offer_ids if params[:offer_ids].present?
  end

  def filter_by_network_ids
    filter do
      @relation.joins(:network).where(networks: { id: params[:network_ids] })
    end
  end

  def filter_by_offer_ids
    filter do
      @relation.joins(:offer).where(offers: { id: params[:offer_ids] })
    end
  end
end
