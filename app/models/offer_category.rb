class OfferCategory < DatabaseRecords::PrimaryRecord
  include Relations::OfferAssociated

  belongs_to :category, inverse_of: :offer_categories, touch: true

  validates :category_id, presence: true, uniqueness: { scope: :offer_id }
  validates :offer_id, presence: true, unless: :offer
end
