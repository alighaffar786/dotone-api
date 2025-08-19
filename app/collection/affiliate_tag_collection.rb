class AffiliateTagCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_name if params[:name].present?
    filter_by_tag_type if params[:tag_type].present?
    filter_by_parent_category_id if params.key?(:parent_category_id)
  end

  def filter_by_name
    filter { @relation.where(name: params[:name]) }
  end

  def filter_by_tag_type
    filter { @relation.where(tag_type: params[:tag_type]) }
  end

  def filter_by_parent_category_id
    filter { @relation.where(parent_category_id: params[:parent_category_id]) }
  end

  def filter_by_search
    filter { @relation.like(params[:search]) }
  end
end
