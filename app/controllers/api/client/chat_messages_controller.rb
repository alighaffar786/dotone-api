class Api::Client::ChatMessagesController < Api::Client::BaseController
  before_action :find_chat_room
  before_action :find_current_participation, only: :create
  load_and_authorize_resource

  def index
    respond_with_pagination paginate(@chat_room.chat_messages)
  end

  def create
    if @chat_message.save
      respond_with @chat_message, status: :created
    else
      respond_with @chat_message, status: :unprocessable_entity
    end
  end

  private

  def find_current_participation
    @current_participation = @chat_room.chat_participations.find_by(
      participant_id: current_user.id, participant_type: @current_user.class.name,
    )
  end

  def find_chat_room
    @chat_room = current_user.chat_rooms.find_by(uuid: params[:chat_room_id])

    raise InvalidParams, 'Participant is not part of this room.' unless @chat_room
  end

  def chat_message_params
    params.require(:chat_message).permit(:content, cdn_urls: []).merge(chat_participation_id: @current_participation.id)
  end
end
