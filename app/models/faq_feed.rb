class FaqFeed < DatabaseRecords::PrimaryRecord
  include AppRoleable
  include DynamicTranslatable

  CATEGORIES = [
    'Account Settings',
    'Offers',
    'Sponsored Events',
    'Reports',
    'Finances',
    'Glossary',
    'Others',
  ].freeze

  validates :title, :content, presence: true
  validates :category, inclusion: { in: CATEGORIES }, presence: true

  before_validation :set_defaults, on: :create

  set_dynamic_translatable_attributes(title: :plain, content: :html)

  private

  def set_defaults
    self.ordinal = FaqFeed.with_roles(role).maximum(:ordinal).to_i + 1
  end
end
