class Api::Client::Teams::ChannelsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :search

  def index
    respond_with query_index
  end

  def search
    authorize! :read, Channel
    respond_with query_search, each_serializer: Teams::Channel::SearchSerializer
  end

  def create
    @channel.owner = current_user

    if @channel.save
      respond_with @channel
    else
      respond_with @channel, status: :unprocessable_entity
    end
  end

  def update
    if @channel.update(channel_params)
      respond_with @channel
    else
      respond_with @channel, status: :unprocessable_entity
    end
  end

  def destroy
    if @channel.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    ChannelCollection.new(current_ability, params).collect.order(name: :asc)
  end

  def query_search
    ChannelCollection.new(current_ability, params).collect
  end

  def channel_params
    params.require(:channel).permit(:name)
  end
end
