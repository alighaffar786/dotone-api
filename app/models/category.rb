class Category < DatabaseRecords::PrimaryRecord
  include Scopeable
  include StaticTranslatable

  belongs_to :category_group, inverse_of: :categories, touch: true

  # TODO: merge offer_categories and text_creative_categories into a single polymorphic table
  # Manage relations from HasCategory helper
  has_many :offer_categories, inverse_of: :category, dependent: :destroy
  has_many :offers, through: :offer_categories

  has_many :site_info_categories, inverse_of: :category, dependent: :destroy
  has_many :site_infos, through: :site_info_categories

  has_many :text_creative_categories, inverse_of: :category, dependent: :destroy
  has_many :text_creatives, through: :text_creative_categories
  has_many :affiliate_prospect_categories, dependent: :destroy
  has_many :affiliate_prospects, through: :affiliate_prospect_categories

  validates :name, presence: true, uniqueness: { scope: :category_group_id }

  set_static_translatable_attributes :name

  scope_by_offer 'offers.id'

  scope :like, -> (*args) { where('categories.name LIKE ?', "%#{args[0]}%") if args[0].present? }
end
