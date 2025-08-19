module Api::Client::SessionHelper
  def validate_domain
    return if auto_auth_token && auto_auth_hosts.include?(auto_auth_token['request_host'])

    render json: { message: 'Invalid Login' }, status: :unauthorized
  end

  def auto_auth_token
    @auto_auth_token ||= DotOne::Utils::JsonWebToken.decode(params[:token])
  rescue StandardError
  end

  def auto_auth_hosts
    ENV.fetch('AUTO_LOGIN_SOURCE_HOSTS').to_s.split(',').map(&:strip)
  end

  def refresh_token
    authorize! :refresh_token, current_user

    if current_user
      current_user.tfa_verified = true
      respond_with_auth_token(current_user)
    else
      render json: { message: 'Invalid token' }, status: :unauthorized
    end
  end

  def respond_with_auth_token(resource)
    if resource
      yield if block_given?
      if auto_auth_token || !resource.tfa_enabled? || (resource.tfa_enabled? && resource.tfa_verified)
        render json: { token: resource.auth_token, expires_in: resource.auth_token_expiration.to_i }
      elsif resource.tfa_enabled? && resource.tfa_verified == false
        render json: { message: '2FA Code is invalid' }
      else
        render json: { tfa_sent: true, message: '2FA Code is sent to your email' }
      end
    else
      render json: { message: 'Invalid Login' }, status: :unauthorized
    end
  end

  def auth_params
    params.permit(:email, :password, :tfa_code).tap do |param|
      param[:login_info] = param.delete(:email)
    end
  end
end
