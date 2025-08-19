# frozen_string_literal: true

class ChatMessageSerializer < ApplicationSerializer
  attributes :id, :content, :created_at, :participant_type, :cdn_urls, :chat_room_uuid
  has_one :participant, through: :chat_participation

  def participant_type
    object.chat_participation.participant_type
  end

  def chat_room_uuid
    object.chat_room.uuid
  end
end
