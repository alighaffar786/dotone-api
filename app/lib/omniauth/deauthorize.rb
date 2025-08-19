class OmniAuth::Deauthorize
  attr_accessor :provider, :payload

  def initialize(provider, payload)
    @provider = provider
    @payload = payload
  end

  def call
    if provider == 'facebook'
      OmniAuth::Facebook::Deauthorize.new(payload).call
    else
      false
    end
  end
end
