# frozen_string_literal: true

class ChatParticipationSerializer < ApplicationSerializer
  attributes :id, :participant_type, :participant_role, :created_at

  has_one :participant
end
