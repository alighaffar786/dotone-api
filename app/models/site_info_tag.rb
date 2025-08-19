class SiteInfoTag < DatabaseRecords::PrimaryRecord
  belongs_to :site_info, inverse_of: :site_info_tag
  belongs_to :affiliate_tag, inverse_of: :site_info_tags
  belongs_to :media_category, -> { media_categories }, class_name: 'AffiliateTag', foreign_key: :affiliate_tag_id
end
