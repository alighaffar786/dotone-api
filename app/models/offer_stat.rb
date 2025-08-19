class OfferStat < DatabaseRecords::PrimaryRecord
  include Relations::OfferAssociated

  validates :offer_id, uniqueness: { scope: [:date, :batch] }, presence: true
  validates :date, :detail_view_count, presence: true
end
