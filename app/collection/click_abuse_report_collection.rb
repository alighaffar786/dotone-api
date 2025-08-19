class ClickAbuseReportCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_blocked
  end

  def ensure_sort
    return default_sorted if sort_field.blank?

    sort_method = "sort_by_#{sort_field}"
    if respond_to?(sort_method, true)
      send(sort_method)
    else
      sort_by_field
    end
  end

  def default_sorted
    sort { @relation.order(updated_at: :desc)}
  end

  def filter_by_search
    filter { @relation.like(params[:search]) }
  end

  def filter_by_blocked
    filter { @relation.where(blocked: false) }
  end
end
