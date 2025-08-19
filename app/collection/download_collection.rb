class DownloadCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present?
    filter_by_owner_ids if params[:owner_ids].present?
  end

  def filter_by_statuses
    filter { @relation.where(status: params[:statuses]) }
  end

  def filter_by_owner_ids
    filter { @relation.owned_by('AffiliateUser', params[:owner_ids]) }
  end

  def filter_by_search
    filter do
      @relation.where('id LIKE :q OR name LIKE :q', q: "%#{params[:search]}%")
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end
end
