class JobStatusCheckCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_job_types if params[:job_type].present?
  end

  def filter_by_job_types
    filter do
      @relation.with_job_types(params[:job_type])
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end
end
