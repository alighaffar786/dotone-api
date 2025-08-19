class Api::Client::Teams::JobStatusChecksController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @job_status_checks = paginate(query_index)
    respond_with_pagination @job_status_checks
  end

  private

  def query_index
    JobStatusCheckCollection.new(@job_status_checks, params).collect
  end
end
