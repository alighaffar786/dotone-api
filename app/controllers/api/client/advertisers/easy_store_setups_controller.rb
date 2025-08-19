class Api::Client::Advertisers::EasyStoreSetupsController < Api::Client::Advertisers::BaseController
  before_action :hmac_valid?, only: :create

  def find
    @easy_store_setup = EasyStoreSetup.accessible_by(current_ability, :read)
      .find_by!(store_domain: params[:store_domain])
    authorize! :read, @easy_store_setup

    respond_with @easy_store_setup
  end

  def create
    @easy_store_setup = EasyStoreSetup.accessible_by(current_ability, :create)
      .where(store_domain: easy_store_setup_params[:store_domain])
      .first_or_initialize

    authorize! :create, @easy_store_setup

    @easy_store_setup.assign_attributes(easy_store_setup_params)
    @easy_store_setup.retrieve_store!

    if @easy_store_setup.save
      @easy_store_setup.deploy_assets!

      respond_with @easy_store_setup.reload
    else
      respond_with @easy_store_setup, status: :unprocessable_entity
    end
  end

  private

  def easy_store_setup_params
    params.require(:easy_store_setup).permit(:store_domain, :code, :offer_id)
  end

  def hmac_valid?
    return true if params[:hmac].blank?

    examine_params = params.except(:controller, :action).permit!.to_h
    hmac = examine_params.delete(:hmac)
    message = examine_params.sort.map { |k, v| "#{k}=#{v}" }.join('&')

    DotOne::ApiClient::ApiWorker::EasyStore.hmac_valid?(hmac, message)
  end
end
