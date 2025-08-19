class Api::V2::Affiliates::BaseController < Api::V2::BaseController
  before_action do
    self.namespace_for_serializer = V2::Affiliates
  end

  def current_user
    super if super.is_a?(Affiliate)
  end
end
