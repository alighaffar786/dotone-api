class Api::Client::Teams::AppConfigsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with @app_configs.with_roles(params[:role]).order(active: :desc)
  end

  def create
    if @app_config.save
      respond_with @app_config
    else
      respond_with @app_config, status: :unprocessable_entity
    end
  end

  def update
    if @app_config.update(app_config_params)
      respond_with @app_config
    else
      respond_with @app_config, status: :unprocessable_entity
    end
  end

  def destroy
    if @app_config.destroy
      head :no_content
    else
      respond_with @app_config, status: :unprocessable_entity
    end
  end

  private

  def app_config_params
    params.require(:app_config).permit(:role, :profile_bg_url, :logo_url, :active)
  end
end
