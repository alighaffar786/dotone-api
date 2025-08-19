class AdSlotOffer < DatabaseRecords::PrimaryRecord
  include Relations::OfferAssociated

  belongs_to :ad_slot, inverse_of: :ad_slot_offers
end
