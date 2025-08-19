class Api::Client::Affiliates::PasswordsController < Api::Client::Affiliates::BaseController
  def reset
    authorize! :reset_password, Affiliate
    @affiliate = Affiliate.find_by_email(params[:email].downcase)

    if @affiliate
      AffiliateMailer.password_reset(@affiliate).deliver_later
      head :ok
    else
      head :not_found
    end
  end

  def create
    authorize! :create_password, Affiliate
    @affiliate = Affiliate.find_by_unique_token(params[:token])

    if @affiliate
      if @affiliate.update(password: params[:password])
        @affiliate.refresh_unique_token
        head :ok
      else
        respond_with @affiliate, status: :unprocessable_entity
      end
    else
      head :not_found
    end
  end

  def update
    authorize! :update, current_user

    if current_user.password_match?(params[:current_password])
      if current_user.update(password: params[:password])
        head :ok
      else
        respond_with current_user, status: :unprocessable_entity
      end
    else
      render json: { message: 'Current password not match' }, status: :unprocessable_entity
    end
  end
end
