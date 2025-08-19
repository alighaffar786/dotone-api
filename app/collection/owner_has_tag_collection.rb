class OwnerHasTagCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_owned_by
    filter_by_affiliate_tag_id if params[:affiliate_tag_id].present?
  end

  def filter_by_owned_by
    filter do
      @relation.owned_by(params[:owner_type], params[:owner_id])
    end
  end

  def filter_by_affiliate_tag_id
    filter do
      @relation.where(affiliate_tag_id: params[:affiliate_tag_id])
    end
  end
end
