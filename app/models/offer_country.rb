class OfferCountry < DatabaseRecords::PrimaryRecord
  include Relations::CountryAssociated
  include Relations::OfferAssociated

  validates :country_id, presence: true, uniqueness: { scope: :offer_id }
  validates :offer_id, presence: true, unless: :offer
end
