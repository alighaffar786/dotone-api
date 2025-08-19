class Api::Client::Teams::ContactListsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index
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

  def destroy
    if @contact_list.destroy
      head :ok
    else
      respond_with @contact_list, status: :unprocessable_entity
    end
  end

  private

  def query_index
    @contact_lists
      .with_statuses(params[:status])
      .owned_by(params[:owner_type], params[:owner_id])
  end

  def contact_list_params
    params.require(:contact_list).permit(
      :email, :first_name, :last_name, :title, :phone, :messenger_service,  :messenger_service_2,
      :messenger_id, :messenger_id_2, :email_optin, :status, :owner_id, :owner_type
    )
  end
end
