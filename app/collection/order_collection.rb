class OrderCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_affiliate_stat_ids if params[:affiliate_stat_ids].present?
  end

  def filter_by_affiliate_stat_ids
    filter { @relation.where(affiliate_stat_id: params[:affiliate_stat_ids]) }
  end

  def filter_by_search
    filter { @relation.where(order_number: params[:search]) }
  end

  def default_sorted
    sort { @relation.order(id: :desc) }
  end
end
