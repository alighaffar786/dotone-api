module BecomeChatter
  extend ActiveSupport::Concern

  included do
    has_many :chat_participations, as: :participant, inverse_of: :participant, dependent: :destroy
    has_many :chat_rooms, through: :chat_participations
    has_many :chat_messages, through: :chat_participations

    has_many :chat_owner_participations,
      -> { where(participant_role: :owner) },
      as: :participant,
      inverse_of: :participant,
      class_name: 'ChatParticipation'

    has_many :owned_chat_rooms, through: :chat_owner_participations, source: :chat_room
  end
end
