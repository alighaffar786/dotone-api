class Api::Client::Affiliates::Auth::SiteInfosController < Api::Client::Affiliates::BaseController
  skip_authorization_check

  def callback
    site_info = send("response_from_#{params[:provider]}", request.env['omniauth.auth'])
    respond_with(site_info)
  end

  private

  def response_from_instagram(auth)
    [auth.dig('extra', 'raw_info', 'site_info')]
  end

  def response_from_facebook(auth)
    fetcher = OmniAuth::Fetcher::Facebook.new(auth)
    fetcher.call_as_site_infos
  end

  def response_from_youtube(_)
    fetcher = OmniAuth::Fetcher::Youtube.new(params[:code])
    fetcher.call_as_site_infos
  end

  def response_from_tiktok(_)
    fetcher = OmniAuth::Fetcher::Tiktok.new(code: params[:code])
    fetcher.call_as_site_infos
  end
end
