class AffiliateSearchLogCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_days_ago if params[:days_ago].present?
  end

  def filter_by_days_ago
    filter { @relation.between(params[:days_ago].to_i.days.ago.to_date..Date.today) }
  end
end
