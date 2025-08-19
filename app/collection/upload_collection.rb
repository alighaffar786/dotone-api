class UploadCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_created_at if params[:start_date].present? && params[:end_date].present?
    filter_by_statuses if params[:statuses].present?
    filter_by_owner_ids if params[:owner_ids].present?
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def filter_by_owner_ids
    filter { @relation.owned_by('AffiliateUser', params[:owner_ids]) }
  end

  def filter_by_search
    filter do
      filter { @relation.like(params[:search]) }
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end
end
