class VtmCampaign < DatabaseRecords::PrimaryRecord
  include Relations::AffiliateAssociated

  validates :name, presence: true, uniqueness: { scope: :affiliate_id }
end
