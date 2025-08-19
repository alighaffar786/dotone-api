class CampaignCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_distinct
    filter_by_channel_ids if params[:channel_ids].present?
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_network_ids if params[:network_ids].present?
  end

  def filter_by_channel_ids
    filter { @relation.where(channel_id: params[:channel_ids]) }
  end

  def filter_by_affiliate_ids
    filter do
      @relation.joins(:affiliates).where(affiliates: { id: params[:affiliate_ids] })
    end
  end

  def filter_by_network_ids
    filter do
      @relation.joins(:networks).where(networks: { id: params[:network_ids] })
    end
  end

  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end
end
