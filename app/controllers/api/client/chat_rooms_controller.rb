class Api::Client::ChatRoomsController < Api::Client::BaseController
  before_action :find_chat_room, only: :create
  load_and_authorize_resource

  def index
    respond_with_pagination paginate(@chat_rooms)
  end

  def create
    if @chat_room.valid?
      respond_with @chat_room, status: :created
    else
      respond_with @chat_room, status: :unprocessable_entity
    end
  end

  private

  def existing_room_id
    ChatRoom.find_existing_room(chat_room_params[:chat_participations_attributes])
  end

  def find_chat_room
    @chat_room = ChatRoom.find_or_initialize_by(id: existing_room_id) do |chat_room|
      ChatRoom.transaction do
        chat_room.update(chat_room_params)
      end
    end
  end

  def chat_room_params
    params
      .require(:chat_room)
      .permit(
        :name, chat_participations_attributes: [:participant_type, :participant_id, :participant_role]
      )
  end
end
