# frozen_string_literal: true

class ChatRoomSerializer < ApplicationSerializer
  attributes :id, :uuid, :name

  has_many :chat_participations
end
