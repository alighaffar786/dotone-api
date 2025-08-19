class Expertise < DatabaseRecords::PrimaryRecord
  include StaticTranslatable

  has_many :expertise_maps, inverse_of: :expertise, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  set_static_translatable_attributes :name
end
