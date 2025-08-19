class Api::V2::Advertisers::BaseController < Api::V2::BaseController
  before_action do
    self.namespace_for_serializer = 'V2::Advertisers'
  end

  def current_user
    super if super.is_a?(Network)
  end
end
