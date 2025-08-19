class ChatParticipation < DatabaseRecords::PrimaryRecord
  PARTICIPANT_TYPES = ['Network', 'Affiliate', 'AffiliateUser']
  PARTICIPANT_ROLES = ['owner', 'participant']

  belongs_to :chat_room, inverse_of: :chat_participations
  belongs_to :participant, polymorphic: true, inverse_of: :chat_participations

  has_many :chat_messages, inverse_of: :chat_participation, dependent: :destroy

  validates :chat_room, :participant, presence: true
  validates :participant_type, inclusion: { in: PARTICIPANT_TYPES }
  validates :participant_role, inclusion: { in: PARTICIPANT_ROLES }
  validates :chat_room_id, uniqueness: { scope: [:participant_id, :participant_type] }
end
