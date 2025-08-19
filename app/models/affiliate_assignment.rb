class AffiliateAssignment < DatabaseRecords::PrimaryRecord
  include LocalTimeZone
  include Relations::AffiliateAssociated

  belongs_to :affiliate_user, inverse_of: :affiliate_assignments, touch: true
  # TODO: deprecate
  belongs_to :advertiser, class_name: 'Network', foreign_key: :network_id, touch: true
  belongs_to :network, inverse_of: :network_assignments, touch: true

  validates :affiliate_user_id, presence: true
  validates :affiliate_id, uniqueness: { scope: :affiliate_user_id, allow_blank: true }
  validates :network_id, uniqueness: { scope: :affiliate_user_id, allow_blank: true }

  set_local_time_attributes :created_at

  scope :network, -> { where.not(network_id: nil) }
  scope :affiliate, -> { where.not(affiliate_id: nil) }
  scope :ordered, -> { order(display_order: :asc) }

  def name
    affiliate_user.full_name
  end
end
