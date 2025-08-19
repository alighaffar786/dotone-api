class Api::Client::Advertisers::ChargesController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @charges = paginate(current_user.charges)
    respond_with_pagination @charges
  end

  def create
    if @charge.save
      respond_with @charge
    else
      respond_with @charge, status: :unprocessable_entity
    end
  end

  private

  def charge_params
    params.permit(:amount, :credit_card_id).merge(network: current_user)
  end
end
