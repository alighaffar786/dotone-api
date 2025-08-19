class CkImage < DatabaseRecords::PrimaryRecord
  has_many :newsletters, foreign_key: :logo_id, inverse_of: :logo, dependent: :nullify

  mount_uploader :image, LegacyImageUploader
end
