class CategoryGroup < DatabaseRecords::PrimaryRecord
  include StaticTranslatable

  # TODO: Delete has_ads column

  has_many :categories, inverse_of: :category_group, dependent: :nullify
  has_many :offers, through: :categories
  has_many :text_creatives, through: :categories

  has_many :advertiser_cats, inverse_of: :category_group, dependent: :destroy
  has_many :advertisers, class_name: 'Network', through: :advertiser_cats

  has_many :ad_slot_category_groups, inverse_of: :category_group, dependent: :destroy
  has_many :ad_slots, through: :ad_slot_category_groups

  has_many :event_has_category_groups, inverse_of: :category_group, dependent: :destroy
  has_many :event_infos, through: :event_has_category_groups

  validates :name, uniqueness: true, presence: true

  set_static_translatable_attributes :name

  scope :like, -> (*args) {
    if args[0].present?
      terms = [args[0]]

      terms += DotOne::I18n.predefined_t('category_group.name')
        .select { |key, value| value.match?(/#{Regexp.escape(args[0])}/i) }
        .keys
        .map(&:to_s)

      query = terms.map { |term| 'category_groups.name LIKE ?' }.join(' OR ')
      values = terms.map { |term| "%#{sanitize_sql_like(term)}%" }

      where(query, *values)
    end
  }

  scope :adult, -> { where(name: 'Adult') }

  def adult?
    name == 'Adult'
  end
end
