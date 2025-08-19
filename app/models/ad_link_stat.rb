class AdLinkStat < DatabaseRecords::PrimaryRecord
  include DateRangeable
  include Relations::AffiliateAssociated

  validates :affiliate_id, uniqueness: { scope: :date }, presence: true
  validates :date, :impression, presence: true
end
