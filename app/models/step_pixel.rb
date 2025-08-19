class StepPixel < DatabaseRecords::PrimaryRecord
  belongs_to :affiliate_offer, inverse_of: :step_pixels
  belongs_to :conversion_step, inverse_of: :step_pixels

  validates :affiliate_offer_id, :conversion_step_id, presence: true
end
