class Api::Client::Advertisers::NetworksController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def current
    authorize! :read, current_user
    respond_with current_user
  end

  def show
    respond_with @network
  end

  def update
    if @network.update(network_params)
      respond_with @network
    else
      respond_with @network, status: :unprocessable_entity
    end
  end

  private

  def network_params
    params.require(:network).permit(
      :name, :contact_name, :contact_phone, :time_zone_id, :currency_id, :locale, :contact_email, :avatar_cdn_url,
      :country_id, :company_url, :tfa_enabled, brands: [], category_group_ids: []
    )
  end
end
