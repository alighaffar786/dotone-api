module DotOne::ClientRoutes
  extend ActiveSupport::Concern
  extend self

  def admin_uploads_url(params = {})
    url_with_params("#{DotOne::Setup.admin_url(params[:locale])}/uploads", params)
  end

  def advertisers_uploads_url(params = {})
    url_with_params("#{DotOne::Setup.advertiser_url(params[:locale])}/uploads", params)
  end

  def affiliates_registration_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/register", params)
  end

  def affiliates_email_verification_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/register/verify", params)
  end

  def affiliates_password_reset_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/password/new", params)
  end

  def affiliates_offer_url(id, params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/offers/#{id}", params)
  end

  def affiliates_event_offer_url(id, params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/events/#{id}", params)
  end

  def affiliates_instagram_callback_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(nil, true)}/oauth/instagram/callback", params)
  end

  def affiliates_line_callback_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(nil, true)}/oauth/line/callback", params)
  end

  def affiliates_tiktok_callback_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(nil, true)}/oauth/tiktok/callback", params)
  end

  def affiliates_youtube_callback_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(nil, true)}/oauth/youtube/callback", params)
  end

  def affiliates_profile_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/profile")
  end

  def advertisers_verification_url(token, params = {})
    "#{DotOne::Setup.advertiser_url(params[:locale])}/register/verify?token=#{token}"
  end

  def advertiser_missing_orders_url(params = {})
    url_with_params("#{DotOne::Setup.advertiser_url(params[:locale])}/order-inquiries", params)
  end

  def advertisers_login_url(params = {})
    url_with_params("#{DotOne::Setup.advertiser_url(params[:locale])}/login", params)
  end

  def affiliates_my_offers_url(params = {})
    url_with_params("#{DotOne::Setup.affiliate_url(params[:locale])}/offers/my-offers", params)
  end

  def url_with_params(url, params = {})
    if params.except(:locale).present?
      "#{url}?#{params.except(:locale).to_query}"
    else
      url
    end
  end
end
