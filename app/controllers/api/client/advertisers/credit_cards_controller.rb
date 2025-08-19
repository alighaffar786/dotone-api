class Api::Client::Advertisers::CreditCardsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @credit_cards = paginate(current_user.credit_cards)
    respond_with_pagination @credit_cards
  end

  def create
    if @credit_card.save
      respond_with @credit_card
    else
      respond_with @credit_card, status: :unprocessable_entity
    end
  end

  def destroy
    if @credit_card.destroy
      respond_with @credit_card
    else
      respond_with @credit_card, status: :unprocessable_entity
    end
  end

  def change_default
    @credit_card.default!
    respond_with @credit_card.reload
  end

  private

  def credit_card_params
    params.require(:credit_card)
      .permit(:token)
      .merge(network: current_user)
  end
end
