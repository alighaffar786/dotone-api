class ChatbotSearchLogCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_locales if params[:locales].present?
    filter_by_owner_type if params[:owner_type].present?
    filter_by_days_ago if params[:days_ago].present?
  end

  def default_sorted
    sort { @relation.order(updated_at: :desc) }
  end

  def sort_by_owner
    sort do
      @relation.order(owner_id: sort_order, owner_type: sort_order)
    end
  end

  def filter_by_locales
    filter { @relation.with_locales(params[:locales]) }
  end

  def filter_by_owner_type
    filter { @relation.where(owner_type: params[:owner_type].classify) }
  end

  def filter_by_search
    filter { @relation.where('keyword LIKE ?', "%#{params[:search]}%") }
  end

  def filter_by_days_ago
    filter { @relation.between(params[:days_ago].to_i.days.ago, Date.today, :updated_at) }
  end
end
