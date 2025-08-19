class Api::Client::Affiliates::SessionsController < Api::Client::Affiliates::BaseController
  include Api::Client::SessionHelper

  before_action :validate_domain, only: :create_by_token
  after_action :trace_login, only: :create

  def create
    authorize! :login, Affiliate

    @affiliate = Affiliate.authenticate(auth_params)
    respond_with_auth_token(@affiliate)
  rescue DotOne::Errors::AccountError, DotOne::Errors::EmailNotVerifiedError => e
    render json: { message: e.details || e.message }, status: :unauthorized
  end

  def create_by_token
    authorize! :login, Affiliate

    @affiliate = Affiliate.find_by(unique_token: auto_auth_token['unique_token'])
    respond_with_auth_token(@affiliate) do
      @affiliate.refresh_unique_token
    end
  end

  private

  def trace_login
    return unless @affiliate

    @affiliate.trace!(Trace::VERB_LOGINS, changes: { login: true, ip_address: request.remote_ip })
    @affiliate.update_login_count
  end
end
