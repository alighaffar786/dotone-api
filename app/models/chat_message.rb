# frozen_string_literal: true

class ChatMessage < DatabaseRecords::PrimaryRecord
  include Broadcastable
  include ActionView::Helpers::SanitizeHelper

  serialize :cdn_urls, Array

  belongs_to :chat_participation, inverse_of: :chat_messages

  has_one :chat_room, through: :chat_participation
  has_one :network, through: :chat_participation, source: :participant, source_type: 'Network'
  has_one :affiliate, through: :chat_participation, source: :participant, source_type: 'Affiliate'
  has_one :affiliate_user, through: :chat_participation, source: :participant, source_type: 'AffiliateUser'

  validates :chat_participation_id, presence: true
  validate  :presence_of_content_or_cdn_urls

  default_scope -> { order(created_at: :desc) }

  def participant
    @participant ||= chat_participation.participant
  end

  def content=(value)
    sanitized_value = sanitize(value.to_s, tags: ['a', 'img', 'b', 's', 'i', 'strong', 'em', 'del', 'br'])
    super(sanitized_value)
  end

  def presence_of_content_or_cdn_urls
    return unless content.blank? and cdn_urls.blank?

    errors.add(:base, 'content or cdn_urls must exist')
  end
end
