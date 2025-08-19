class OmniAuth::Facebook::Deletion
  attr_accessor :data

  def initialize(signed_request)
    secret = ENV.fetch('FACEBOOK_APP_SECRET', '')
    @data = OmniAuth::Facebook::SignedRequest.parse(signed_request, secret)
  rescue StandardError => e
    Rails.logger.error e
    @data = nil
  end

  def valid?
    data.present?
  end

  def call
    return false unless valid?

    deletion
  end

  def deletion
    affiliate = Affiliate.find_by(facebook_id: data['user_id'])
    return if affiliate.nil?

    payload = { provider: 'facebook', user_id: data['user_id'] }

    UserMailer.deletion(affiliate, payload).deliver_later
  end
end
