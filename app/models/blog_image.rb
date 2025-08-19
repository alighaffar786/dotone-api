class BlogImage < DatabaseRecords::PrimaryRecord
  has_one :blog_content, inverse_of: :blog_image, dependent: :nullify

  before_save :save_image_dimensions

  mount_uploader :image, LegacyImageUploader

  validates :cdn_url, presence: true

  scope :like, -> (*args) { where('id LIKE ?', "%#{args[0]}%") if args[0].present? }

  def cdn_url
    super.presence || image_url
  end

  private

  def save_image_dimensions
    return unless image_changed?

    self.width = image.geometry[:width]
    self.height = image.geometry[:height]
  end
end
