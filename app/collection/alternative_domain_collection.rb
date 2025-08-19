class AlternativeDomainCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_is_visibles
    filter_by_statuses if params[:statuses].present?
    filter_by_host_types
  end

  def filter_by_is_visibles
    filter { @relation.where(visible: params[:visibles].presence || true) }
  end

  def filter_by_statuses
    filter { @relation.with_statuses(params[:statuses]) }
  end

  def filter_by_host_types
    filter { @relation.with_host_types(params[:host_types].presence || AlternativeDomain.host_type_tracking) }
  end

  def filter_by_search
    filter do
      @relation.where('host LIKE :q OR name_servers LIKE :q OR load_balancer_dns_name LIKE :q', q: "%#{params[:search]}%")
    end
  end

  def default_sorted
    sort { @relation.order(updated_at: :desc) }
  end
end
