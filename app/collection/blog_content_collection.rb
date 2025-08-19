class BlogContentCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_statuses if params[:statuses].present?
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def default_sorted
    sort { @relation.order(posted_at: :desc, id: :desc) }
  end
end
