class ChatbotSearchLog < DatabaseRecords::PrimaryRecord
  include DateRangeable
  include Owned
  include Relations::LanguageAssociated

  validates :keyword, :owner, presence: true
  validates :owner_id, uniqueness: { scope: [:owner_type, :keyword] }

  def keyword=(value)
    super(value.gsub(/[^[:word:]\s]/, ''))
  end
end
