class Api::Client::Affiliates::AffiliateAddressesController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource through: :current_user, singleton: true

  def show
    respond_with @affiliate_address
  end

  def update
    if @affiliate_address.update(affiliate_address_params)
      respond_with @affiliate_address
    else
      respond_with @affiliate_address, status: :unprocessable_entity
    end
  end

  private

  def affiliate_address_params
    params.require(:affiliate_address).permit(
      :address_1, :address_2, :city, :state, :zip_code, :country_id
    )
  end
end
