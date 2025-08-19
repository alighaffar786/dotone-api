class Language < DatabaseRecords::PrimaryRecord
  include ModelCacheable

  has_many :affiliates, inverse_of: :language, dependent: :nullify
  has_many :affiliate_stats, inverse_of: :language, dependent: :nullify
  has_many :affiliate_stat_converted_ats, inverse_of: :language, dependent: :nullify
  has_many :affiliate_stat_captured_ats, inverse_of: :language, dependent: :nullify
  has_many :affiliate_stat_published_ats, inverse_of: :language, dependent: :nullify
  has_many :affiliate_users, inverse_of: :language, dependent: :nullify
  has_many :chatbot_search_logs, inverse_of: :language, dependent: :nullify
  has_many :easy_store_setups, inverse_of: :language, dependent: :nullify
  has_many :shopify_setups, inverse_of: :language, dependent: :nullify
  has_many :networks, inverse_of: :language, dependent: :nullify
  has_many :wl_companies, inverse_of: :language, dependent: :nullify

  validates :name, :locale, presence: true
  validates :locale, uniqueness: true

  alias_attribute :locale, :code

  def self.default
    @default ||= cached_find_by(locale: default_locale)
  end

  def self.platform
    @platform ||= DotOne::Setup.platform_language || default
  end

  def self.default_locale
    'en-US'
  end

  def self.current_locale
    DotOne::Current.locale
  end

  def self.platform_locale
    platform.locale
  end

  def self.all_locales
    @all_locales ||= pluck(:locale)
  end

  # print the summary text for this language
  def summary(type = 'long')
    if type == 'code'
      locale.downcase.gsub('-', '_')
    elsif type == 'short_code'
      locale.split('-').last.downcase
    else
      "#{name} (#{locale})"
    end
  rescue StandardError
  end
end
