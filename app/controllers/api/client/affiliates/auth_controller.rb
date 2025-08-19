class Api::Client::Affiliates::AuthController < Api::Client::Affiliates::BaseController
  include Api::Client::SessionHelper

  skip_authorization_check except: :callback
  after_action :trace_login, only: :callback

  def callback
    authorize! :signup, Affiliate

    @affiliate = Affiliate.from_omniauth(request.env['omniauth.auth'])
    @affiliate.locale = current_locale if @affiliate.new_record?

    if @affiliate.persisted? && !@affiliate.can_login?
      raise DotOne::Errors::AccountError.new(@affiliate.id, 'Account Not Active', @affiliate)
    elsif @affiliate.save
      @affiliate.tfa_verified = true
      respond_with_auth_token(@affiliate)
    else
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def failure
    render json: { message: params[:message] }, status: :unauthorized
  end

  def deauthorize
    @deauthorize = OmniAuth::Deauthorize.new(params[:provider], params[:signed_request])

    head @deauthorize.call ? 200 : 422
  end

  def deletion
    @deletion = OmniAuth::Deletion.new(params[:provider], params[:signed_request])

    head @deletion.call ? 200 : 422
  end

  private

  def trace_login
    return unless @affiliate&.persisted?

    @affiliate.trace!(Trace::VERB_LOGINS, { changes: { login: true, ip_address: request.remote_ip } })
    @affiliate.update_login_count
  end
end
