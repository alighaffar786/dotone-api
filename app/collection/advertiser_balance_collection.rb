class AdvertiserBalanceCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_network_ids if params[:network_ids].present?
    filter_by_record_types if params[:record_types].present?
    filter_by_billing_region if params[:billing_region].present?
  end

  def filter_by_network_ids
    filter { @relation.with_networks(params[:network_ids]) }
  end

  def filter_by_record_types
    filter { @relation.with_record_types(params[:record_types]) }
  end

  def filter_by_billing_region
    filter { @relation.with_billing_regions(params[:billing_region]) }
  end

  def default_sorted
    sort { @relation.recent }
  end
end
