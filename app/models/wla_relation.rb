class WlaRelation < DatabaseRecords::PrimaryRecord
  belongs_to :manager, class_name: 'AffiliateUser'
  belongs_to :member, class_name: 'AffiliateUser'
end
