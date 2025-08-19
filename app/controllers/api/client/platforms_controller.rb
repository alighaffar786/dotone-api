class Api::Client::PlatformsController < Api::Client::BaseController
  skip_authorization_check

  def show
    respond_with WlCompany.default, serializer: PlatformSerializer
  end
end
