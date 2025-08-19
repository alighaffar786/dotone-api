# frozen_string_literal: true

module Broadcastable
  extend ActiveSupport::Concern

  included do
    include CurrentHandler

    after_create_commit :broadcast_message
  end

  def broadcast_message
    ActionCable.server.broadcast("#{chat_room.uuid}_room", serialize_message.as_json)
  end

  def serialize_message
    ActiveModelSerializers::SerializableResource.new(self, serializer: ChatMessageSerializer,
      root: :data,
      meta: meta_options)
  end

  def meta_options
    {
      locale: current_locale,
      currency: current_currency_code,
      time_zone: current_gmt,
    }
  end

  def params
    {}
  end

  def current_user
    @current_user ||= participant
  end
end
