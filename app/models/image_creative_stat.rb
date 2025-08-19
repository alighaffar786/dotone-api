class ImageCreativeStat < DatabaseRecords::PrimaryRecord
  belongs_to :image_creative, inverse_of: :image_creative_stats

  validates :image_creative_id, uniqueness: { scope: :date }, presence: true
  validates :date, :ui_download_count, presence: true

  def record_ui_download!
    self.ui_download_count += 1
    save!
  end
end
