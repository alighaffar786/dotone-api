class Api::Client::TrackingUrlsController < Api::Client::BaseController
  def generate_global_conversion_url
    authorize! :create, :tracking_link
    url = DotOne::Track::Routes.global_postback_url(clean_params)
    respond_with({ url: url })
  end

  private

  def clean_params
    network = Network.accessible_by(current_ability).find(params[:network_id]) if params[:network_id]
    current_params = tracking_url_params.except(:network_id).to_h
    current_params = current_params.merge(network.s2s_params) if network.present?

    DotOne::Track::TokenProcessor.cleanup_params_token(current_params)
  end

  def tracking_url_params
    params.require(:tracking_url).permit(:step, :network_id, :server_subid, :order, :order_total, :revenue)
  end
end
