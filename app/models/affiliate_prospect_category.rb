class AffiliateProspectCategory < DatabaseRecords::PrimaryRecord
  belongs_to :affiliate_prospect, inverse_of: :affiliate_prospect_categories
  belongs_to :category, inverse_of: :affiliate_prospect_categories
end
