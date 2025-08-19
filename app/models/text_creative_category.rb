class TextCreativeCategory < DatabaseRecords::PrimaryRecord
  belongs_to :category, inverse_of: :text_creative_categories, touch: true
  belongs_to :text_creative, inverse_of: :text_creative_categories, touch: true

  validates :category_id, presence: true
  validates :text_creative_id, presence: true, unless: :new_record?
  validates :text_creative_id, uniqueness: { scope: :category_id }
end
