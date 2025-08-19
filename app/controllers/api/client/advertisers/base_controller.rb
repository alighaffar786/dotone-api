# Base class for advertiser user class
class Api::Client::Advertisers::BaseController < Api::Client::BaseController
  before_action do
    self.namespace_for_serializer = Advertisers
  end

  def current_user
    super if super.is_a?(Network) && super.active?
  end
end
