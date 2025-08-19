class VtmPixel < DatabaseRecords::PrimaryRecord
  belongs_to :vtm_channel, inverse_of: :vtm_pixels, touch: true

  validates :step_name, uniqueness: { scope: :vtm_channel_id }
end
