class Creative < DatabaseRecords::PrimaryRecord
  belongs_to :entity, polymorphic: true, inverse_of: :creatives, touch: true
  belongs_to :offer_variant, inverse_of: :creatives, touch: true
  belongs_to :image_creative, foreign_key: :entity_id
  belongs_to :text_creative, foreign_key: :entity_id

  validates :offer_variant_id, uniqueness: { scope: [:entity_id, :entity_type] }, presence: true
  validates :entity_id, :entity_type, presence: true, unless: :entity
end
