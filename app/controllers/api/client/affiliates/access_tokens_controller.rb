class Api::Client::Affiliates::AccessTokensController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource

  def index
    respond_with @access_tokens.preload(:partner_app)
  end

  def create
    if @access_token.save
      respond_with @access_token
    else
      respond_with @access_token, status: :unprocessable_entity
    end
  end

  def update
    if @access_token.update(access_token_params)
      respond_with @access_token
    else
      respond_with @access_token, status: :unprocessable_entity
    end
  end

  def destroy
    if @access_token.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def access_token_params
    params.require(:access_token).permit(:status, :partner_app_id)
  end
end
