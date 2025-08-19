# NOTE: Deprecated
class StatScoreInfo < DatabaseRecords::PrimaryRecord
  include Relations::AffiliateStatAssociated

  belongs_to_affiliate_stat inverse_of: :stat_score_info
end
