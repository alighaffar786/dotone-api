class Api::Client::AppConfigsController < Api::Client::BaseController
  before_action :set_app_config

  authorize_resource

  def show
    respond_with @app_config
  end

  private

  def set_app_config
    @app_config = AppConfig.accessible_by(current_ability).first!
  end
end
