class Api::Client::Advertisers::ContactListsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    respond_with @contact_lists
  end

  def create
    if @contact_list.save
      respond_with @contact_list
    else
      respond_with @contact_list, status: :unprocessable_entity
    end
  end

  def update
    if @contact_list.update(contact_list_params)
      respond_with @contact_list
    else
      respond_with @contact_list, status: :unprocessable_entity
    end
  end

  private

  def contact_list_params
    params.require(:contact_list).permit(
      :email, :first_name, :last_name, :title, :phone, :messenger_service,
      :messenger_id, :email_optin, :status
    )
  end
end
