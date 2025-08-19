class Api::Client::Advertisers::ClientApisController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  after_action :send_product_api_update_notification, only: [:create, :update]

  def index
    respond_with_pagination paginate(query_index)
  end

  def create
    if @client_api.save
      respond_with @client_api
    else
      respond_with @client_api, status: :unprocessable_entity
    end
  end

  def update
    if @client_api.update(client_api_params)
      respond_with @client_api
    else
      respond_with @client_api, status: :unprocessable_entity
    end
  end

  private

  def query_index
    ClientApiCollection.new(@client_apis, params)
      .collect
      .preload(owner: [:name_translations])
  end

  def client_api_params
    params.require(:client_api).permit(:name, :owner_id, :host, :username, :password).tap do |param|
      param[:status] = ClientApi.status_pending
    end
  end

  def send_product_api_update_notification
    return unless @client_api.product_api? && current_user.affiliate_users.present?

    AffiliateUserMailer.notify_product_api_update(@client_api.owner_id, current_user).deliver_later
  end
end
