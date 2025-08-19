class Api::Client::Advertisers::PasswordsController < Api::Client::Advertisers::BaseController
  def reset
    authorize! :reset_password, Network
    @network = Network.active.find_by_contact_email(params[:email])

    if @network
      send_reset_notification
      head :ok
    else
      render json: { message: 'Invalid Email' }, status: :not_found
    end
  end

  def create
    authorize! :create_password, Network
    @network = Network.find_by(unique_token: params[:token])

    if @network
      if @network.update(password: params[:password])
        @network.refresh_unique_token
        render json: { message: 'Success' }
      else
        respond_with @network, status: :unprocessable_entity
      end
    else
      render json: { message: 'Invalid Token' }, status: :not_found
    end
  end

  def update
    authorize! :update, current_user

    if current_user.update(password: params[:password])
      head :ok
    else
      respond_with current_user, status: :unprocessable_entity
    end
  end

  private

  def send_reset_notification
    @network.refresh_unique_token
    AdvertiserMailer.password_reset_instruction_email(@network).deliver_later
  end
end
