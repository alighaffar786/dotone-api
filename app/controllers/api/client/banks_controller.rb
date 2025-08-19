class Api::Client::BanksController < Api::Client::BaseController
  skip_authorization_check

  def index
    respond_with Bank.all
  end

  def branches
    respond_with Bank.get_branches(bank_id: params[:id])
  end
end
