class OfferConversionPixel < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Relations::OfferAssociated

  PIXEL_TYPES  = [
    'API',
    'Javascript',
    'S2S',
    'HTML',
  ].freeze

  validates :pixel_type, inclusion: { in: PIXEL_TYPES }, uniqueness: { scope: :offer_id }, allow_blank: true

  define_constant_methods PIXEL_TYPES, :pixel_type
end
