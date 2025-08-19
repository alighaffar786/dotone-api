class OmniAuth::Deletion
  def initialize(provider, payload)
    @provider = provider
    @payload = payload
  end

  def call
    if @provider == 'facebook'
      OmniAuth::Facebook::Deletion.new(@payload).call
    else
      false
    end
  end
end
