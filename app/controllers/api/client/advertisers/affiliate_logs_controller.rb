class Api::Client::Advertisers::AffiliateLogsController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def create
    @affiliate_log.agent = current_user
    authorize! :read, @affiliate_log.owner

    if @affiliate_log.save
      respond_with @affiliate_log
    else
      respond_with @affiliate_log, status: :unprocessable_entity
    end
  end

  private

  def affiliate_log_params
    params.require(:affiliate_log).permit(:owner_id, :owner_type, :notes)
  end
end
