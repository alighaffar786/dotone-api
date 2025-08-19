class Api::Client::Teams::AffiliateUsersController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :current

  before_action :validate_origin_presence, only: :generate_auto_auth_token

  def index
    respond_with query_index
  end

  def current
    authorize! :read, current_user
    respond_with current_user
  end

  def show
    authorize! :read_user, @affiliate_user unless @affiliate_user.id == current_user.id
    respond_with @affiliate_user
  end

  def create
    @affiliate_user = AffiliateUser.new(affiliate_user_params)
    authorize! :create_user, @affiliate_user

    if @affiliate_user.save
      respond_with @affiliate_user
    else
      respond_with @affiliate_user, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update_user, @affiliate_user unless @affiliate_user.id == current_user.id

    if @affiliate_user.update(affiliate_user_params)
      respond_with @affiliate_user
    else
      respond_with @affiliate_user, status: :unprocessable_entity
    end
  end

  def generate_auto_auth_token
    authorize! :login_as, @affiliate_user

    @affiliate_user.refresh_unique_token if @affiliate_user.unique_token.blank?
    token = DotOne::Utils::JsonWebToken.encode(
      unique_token: @affiliate_user.unique_token,
      request_host: URI(request.origin).host,
    )
    render json: { token: token }
  end

  private

  def query_index
    AffiliateUserCollection.new(@affiliate_users, params).collect
  end

  def affiliate_user_params
    params.require(:affiliate_user).permit(
      :currency_id, :time_zone_id, :locale, :title, :first_name, :last_name, :direct_phone, :mobile_phone, :fax, :email,
      :line, :skype, :wechat, :qq, :avatar_cdn_url, :username, :password, :status, :roles, :tfa_enabled
    ).tap do |param|
      param.delete(:password) if param[:password].blank?
      param.reject! { |key| [:username, :password, :status, :roles].include?(key.to_sym) } unless current_user.admin?
    end
  end
end
