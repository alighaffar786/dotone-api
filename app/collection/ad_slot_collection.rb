class AdSlotCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_distinct
    filter_by_affiliate_id if params[:affiliate_id].present?
    filter_by_category_group_ids if params[:category_group_ids].present?
    filter_by_dimensions if params[:dimensions].present?
  end

  def filter_by_affiliate_id
    filter { @relation.where(affiliate_id: params[:affiliate_id]) }
  end

  def filter_by_category_group_ids
    filter { @relation.with_category_groups(params[:category_group_ids]) }
  end

  def filter_by_dimensions
    filter { @relation.with_dimensions(params[:dimensions]) }
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end
end
