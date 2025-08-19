class ProductCategory < DatabaseRecords::PrimaryRecord
  include BulkInsertable
  include Relations::OfferAssociated

  validates :name, presence: true
end
