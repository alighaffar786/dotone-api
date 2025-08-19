class Api::Client::Teams::JobsController < Api::Client::Teams::BaseController
  def index
    authorize! :read, Delayed::Job
    @jobs = paginate(query_index)
    respond_with_pagination @jobs
  end

  def destroy
    authorize! :destroy, Delayed::Job
    if params[:id].present?
      Delayed::Job.where(id: params[:id]).destroy_all
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def bulk_delete
    authorize! :destroy, Delayed::Job
    if params[:ids].present?
      Delayed::Job.where(id: params[:ids]).destroy_all
      head :ok
    else
      head :bad_request
    end
  end

  private

  def query_index
    Delayed::JobCollection.new(current_ability, params).collect
  end
end
