class Country < DatabaseRecords::PrimaryRecord
  include ModelCacheable
  include StaticTranslatable
  include Relations::CurrencyAssociated

  CONTINENT_CODES = {
    'Africa' => 'AF',
    'Antarctica' => 'AN',
    'Asia' => 'AS',
    'Europe' => 'EU',
    'North America' => 'NA',
    'Oceania' => 'OC',
    'South America' => 'SA',
  }.freeze

  alias_attribute :code, :iso_2_country_code

  has_many :offer_countries, inverse_of: :country, dependent: :destroy
  has_many :offers, through: :offer_countries
  has_many :affiliate_addresses, inverse_of: :country, dependent: :nullify
  has_many :affiliate_payments, inverse_of: :country, dependent: :nullify
  has_many :networks, inverse_of: :country, dependent: :nullify
  has_many :affiliate_prospects, inverse_of: :country, dependent: :nullify

  has_many :affiliate_feed_countries, inverse_of: :country
  has_many :affiliate_feeds, through: :affiliate_feed_countries

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { is: 2 }
  validates :iso_3_country_code, presence: true, uniqueness: true, length: { is: 3 }
  validates :continent, presence: true

  set_static_translatable_attributes :name, :continent

  scope :with_iso_2_country_code, -> (*args) { where(iso_2_country_code: args.flatten) if args[0].present? }
  scope :with_iso_3_country_code, -> (*args) { where(iso_3_country_code: args.flatten) if args[0].present? }

  scope :like, -> (*args) {
    if args[0].present?
      where(id: args.flatten)
        .or(where('countries.name LIKE :q OR iso_2_country_code LIKE :q OR iso_3_country_code LIKE :q', q: "%#{args[0]}%"))
    end
  }

  def self.international
    cached_find_by(name: 'International') 
  end

  def continent
    self[:continent].presence || 'Other'
  end

  def continent_code
    CONTINENT_CODES.fetch(continent, 'Other')
  end
end
