class AffiliateFeedCountry < DatabaseRecords::PrimaryRecord
  include Relations::CountryAssociated

  belongs_to :affiliate_feed, inverse_of: :affiliate_feed_countries

  validates :country, uniqueness: { scope: :affiliate_feed }
  validates :country, :affiliate_feed, presence: true
end
