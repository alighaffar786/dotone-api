class Api::Client::Advertisers::AdvertiserBalancesController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    respond_with_pagination paginate(query_index), meta: { final_balance: current_user.forex_current_balance(current_currency_code) }
  end

  private

  def query_index
    @advertiser_balances.recent.preload(:network)
  end
end
