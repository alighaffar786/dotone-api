class ExpertiseMap < DatabaseRecords::PrimaryRecord
  include Relations::AffiliateAssociated

  belongs_to :expertise, inverse_of: :expertise_maps
end
