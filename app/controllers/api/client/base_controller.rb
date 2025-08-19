class Api::Client::BaseController < Api::BaseController
  include Api::Client::RequestHandler
  include Api::Client::ResponseHandler
  include Api::Client::DownloadHelper

  def current_user
    return unless auth_token.is_a?(Hash)

    @current_user ||= auth_token['user_type'].constantize.find_by(id: auth_token['id'])
  rescue
  end

  def start_bulk_update_job(job, update_params)
    return if update_params.empty?

    job.perform_later(
      user: current_user,
      ids: params[:ids],
      params: update_params.to_h,
    )
  end

  protected

  def auth_header
    return if request.headers['Authorization'].blank?

    @auth_header ||= request.headers['Authorization'].split(' ').last
  end

  def auth_token
    @auth_token ||= DotOne::Utils::JsonWebToken.decode(auth_header)
  rescue StandardError
  end
end
