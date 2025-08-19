class Delayed::JobCollection < BaseCollection
  private

  def filter_by_search
    filter do
      Delayed::Job.where('id LIKE :q OR job_type LIKE :q OR queue LIKE :q OR owner_type LIKE :q OR owner_id LIKE :q OR handler LIKE :q OR last_error LIKE :q', q: "%#{params[:search]}%")
    end
  end
end
