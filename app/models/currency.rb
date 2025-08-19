class Currency < DatabaseRecords::PrimaryRecord
  include ModelCacheable
  include StaticTranslatable

  # Available currencies to use
  # for this application. For available
  # currencies on payment, please checkout
  # AffiliatePayment model
  AVAILABLE_CURRENCIES = [
    :TWD,
    :CNY,
    :JPY,
    :HKD,
    :SGD,
    :USD,
    :EUR,
    :GBP,
    :AUD,
    :IDR,
    :MYR,
    :THB,
    :CAD,
  ]

  SYMBOLS = {
    CAD: 'C$',
    CNY: '¥',
    IDR: 'Rp',
    MYR: 'RM',
    THB: '฿',
    TWD: 'NT$',
    GBP: '£',
    EUR: '€',
    AUD: 'AUD$',
    HKD: 'HK$',
    SGD: 'SG$',
    JPY: '¥',
    USD: '$',
  }

  # Lists of currency code
  # where the amount has no decimal point
  INTEGER_CURRENCY_CODES = [:TWD, :CNY]

  # TODO: : tables on primary db
  has_many :affiliates, inverse_of: :currency, dependent: :nullify
  has_many :affiliate_users, inverse_of: :currency, dependent: :nullify
  has_many :countries, inverse_of: :currency, dependent: :nullify
  has_many :conversion_steps, foreign_key: :true_currency_id, inverse_of: :true_currency, dependent: :nullify
  has_many :missing_orders, inverse_of: :currency, dependent: :nullify
  has_many :networks, inverse_of: :currency, dependent: :nullify

  has_many :users, inverse_of: :currency, dependent: :nullify
  has_many :wl_companies, inverse_of: :currency, dependent: :nullify
  has_many :text_creatives, inverse_of: :currency, dependent: :nullify
  has_many :ads, inverse_of: :currency, dependent: :nullify

  validates :name, :code, presence: true, uniqueness: { case_sensitive: true }

  set_static_translatable_attributes :code_name

  alias_attribute :code_name, :code

  def self.default
    @default ||= cached_find_by(code: default_code)
  end

  def self.platform
    @platform ||= DotOne::Setup.platform_currency || default
  end

  def self.current
    DotOne::Current.currency
  end

  def self.default_code
    'USD'
  end

  def self.platform_code
    platform.code
  end

  def self.current_code
    current.code
  end

  def self.converter
    DotOne::Utils::CurrencyConverter
  end

  def self.platform_rate_map
    @platform_rate_map ||= converter.generate_rate_map
  end

  def self.default_rate_map
    @default_rate_map ||= converter.generate_rate_map(default_code)
  end

  def self.rate(from, to, rate_map = {})
    converter.convert_rate(from, to, rate_map)
  end

  def self.rate_from_platform(to)
    rate(platform_code, to, platform_rate_map)
  end

  def self.rate_from_default(to)
    rate(default_code, to, default_rate_map)
  end

  def self.integer_currency_code?(code)
    INTEGER_CURRENCY_CODES.include?(code&.to_sym)
  end

  def self.currency_valid?(code)
    AVAILABLE_CURRENCIES.include?(code&.to_sym)
  end

  def self.as_rate_sql(column, to_currency_code = Currency.default_code)
    cases = Currency.all.map do |currency|
      rate = converter.convert_rate(currency.code, to_currency_code) rescue 1
      <<-SQL.squish
        WHEN #{currency.id} THEN #{rate}
      SQL
    end

    <<-SQL.squish
      CASE #{column} #{cases.join} ELSE #{rate_from_platform(to_currency_code)} END
    SQL
  end

  def platform?
    code === Currency.platform_code
  end

  def symbol
    SYMBOLS[code&.to_sym]
  end
end
