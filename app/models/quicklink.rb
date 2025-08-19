class Quicklink < DatabaseRecords::PrimaryRecord
  include Owned

  NAME_CONVERTRACK_HOME = 'HomePage'

  OWNER_TYPES = ['Affiliate', 'Network', 'User', 'AffiliateUser']
end
