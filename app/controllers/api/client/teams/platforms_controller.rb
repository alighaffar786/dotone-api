class Api::Client::Teams::PlatformsController < Api::Client::Teams::BaseController
  before_action :set_platform

  def update
    authorize! :update, @platform
    if @platform.update(platform_params)
      WlCompany.default = @platform.reload
      respond_with @platform, serializer: Teams::PlatformSerializer
    else
      respond_with @platform, status: :unprocessable_entity
    end
  end

  def show
    authorize! :read, @platform
    respond_with @platform, serializer: Teams::PlatformSerializer
  end

  private

  def set_platform
    @platform = DotOne::Setup.wl_company
  end

  def refresh_token(token)
    client = Koala::Facebook::OAuth.new.exchange_access_token_info(token)
    client['access_token']
  rescue Koala::Facebook::OAuthTokenRequestError => e
    if Rails.env.production?
      Sentry.capture_exception(e)
    else
      raise e
    end
  end

  def platform_params
    params
      .require(:platform)
      .permit(
        :address, :affiliate_contact_email, :affiliate_terms, :general_contact_email, :name,
        setup: {}, translations_attributes: [:id, :locale, :field, :content]
      ).tap do |param|
        param[:setup][:facebook_access_token] = refresh_token(param[:setup].delete(:facebook_access_token)) if params.dig(:setup, :facebook_access_token).present?
      end
  end
end
