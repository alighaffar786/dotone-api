class Api::Client::Teams::PasswordsController < Api::Client::Teams::BaseController
  def reset
    authorize! :reset_password, AffiliateUser
    @affiliate_user = AffiliateUser.find_by_email(params[:email].downcase)

    if @affiliate_user
      UserMailer.password_reset_instructions(@affiliate_user).deliver_later
      head :ok
    else
      head :not_found
    end
  end

  def create
    authorize! :create_password, AffiliateUser
    @affiliate_user = AffiliateUser.find_by_unique_token(params[:token])

    if @affiliate_user
      if @affiliate_user.update(password: params[:password])
        @affiliate_user.refresh_unique_token
        head :ok
      else
        respond_with @affiliate_user, status: :unprocessable_entity
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
