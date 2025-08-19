class OmniAuth::Fetcher::Youtube
  attr_accessor :auth

  def initialize(code)
    @auth = Token.new(code: code).auth
  end

  def call_as_site_infos
    channels.map do |channel|
      Channel.new(channel, auth).site_info_attributes
    end
  end

  private

  def channels
    @channels ||= Channel.all(auth)
  end
end
