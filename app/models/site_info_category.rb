class SiteInfoCategory < DatabaseRecords::PrimaryRecord
  belongs_to :site_info, inverse_of: :site_info_categories
  belongs_to :category, inverse_of: :site_info_categories

  validates :site_info_id, uniqueness: { scope: :category_id }
end
