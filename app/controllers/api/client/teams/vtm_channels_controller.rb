class Api::Client::Teams::VtmChannelsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    @vtm_channels = paginate(query_index)
    respond_with_pagination @vtm_channels
  end

  def update
    if @vtm_channel.update(vtm_channel_params)
      respond_with @vtm_channel
    else
      respond_with @vtm_channel, status: :unprocessable_entity
    end
  end

  private

  def query_index
    VtmChannelCollection.new(current_ability, params)
      .collect
      .preload(:mkt_site, :network, :vtm_pixels, offer: [:name_translations])
  end

  def vtm_channel_params
    params
      .require(:vtm_channel)
      .permit(
        :conv_pixel,
        :visit_pixel,
        vtm_pixels_attributes: [:id, :order_conv_pixel, :step_name, :_destroy],
      )
  end
end
