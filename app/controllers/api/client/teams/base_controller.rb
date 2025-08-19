class Api::Client::Teams::BaseController < Api::Client::BaseController
  before_action do
    self.namespace_for_serializer = Teams
  end

  def current_user
    super if super.is_a?(AffiliateUser) && super.active?
  end
end
