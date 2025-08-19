class OfferTerm < DatabaseRecords::PrimaryRecord
  belongs_to :offer, touch: true
  belongs_to :term, touch: true
end
