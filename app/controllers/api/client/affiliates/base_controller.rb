# Base class for affiliate user class
class Api::Client::Affiliates::BaseController < Api::Client::BaseController
  before_action do
    self.namespace_for_serializer = Affiliates
  end

  def current_user
    super if super.is_a?(Affiliate) && super.can_login?
  end
end
