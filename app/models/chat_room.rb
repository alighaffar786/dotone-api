class ChatRoom < DatabaseRecords::PrimaryRecord
  has_many :chat_participations, inverse_of: :chat_room, dependent: :destroy
  has_many :chat_messages, through: :chat_participations
  has_many :affiliates, through: :chat_participations, source: :participant, source_type: 'Affiliate'
  has_many :networks, through: :chat_participations, source: :participant, source_type: 'Network'
  has_many :affiliate_users, through: :chat_participations, source: :participant, source_type: 'AffiliateUser'

  has_one :owner_participation, -> { where(participant_role: :owner) }, class_name: 'ChatParticipation',
    inverse_of: :chat_room, autosave: true

  validates :name, :uuid, presence: true, uniqueness: true
  before_validation :set_uuid

  accepts_nested_attributes_for :chat_participations

  default_scope { includes(:chat_messages).order('chat_messages.created_at desc') }

  # NOTE: Owner logic just in case if we decide to give the
  # ChatRoom creaters a wider auth rules compared to participants
  def owner
    @owner ||= owner_participation&.participant
  end

  def owner=(value)
    owner_participation || build_owner_participation
    owner_participation.participant = value
    @owner = value
  end

  def owner_id
    @owner_id ||= owner_participation&.participant_id
  end

  def owner_id=(value)
    owner_participation || build_owner_participation
    owner_participation.participant_id = value
    @owner_id = value
  end

  def owner_type
    @owner_type ||= owner_participation&.participant_type
  end

  def owner_type=(value)
    owner_participation || build_owner_participation
    owner_participation.participant_type = value
    @owner_type = value
  end

  def participants
    chat_participations.map(&:participant)
  end

  def previous_messages(current_message, limit = 10)
    chat_messages
      .where('chat_messages.created_at <= ?', current_message.created_at)
      .where.not(id: current_message.id)
      .limit(limit)
  end

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def next_messages(current_message, limit = 10)
    chat_messages
      .where('chat_messages.created_at >= ?', current_message.created_at)
      .where.not(id: current_message.id)
      .limit(limit)
  end

  def self.find_existing_room(participants_params)
    ChatParticipation.where(participant_type: participants_params[0]['participant_type'],
      participant_id: participants_params[0]['participant_id'])
      .where(chat_room_id: ChatParticipation.where(participant_type: participants_params[1]['participant_type'],
        participant_id: participants_params[1]['participant_id'])
      .pluck(:chat_room_id))
      .pluck(:chat_room_id).first
  end
end
