class SiteInfo < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include HasKeywords
  include Scopeable
  include Relations::AffiliateAssociated
  include Relations::HasCategoryGroups

  # TODO: Delete
  STATUSES = ['Active', 'Deleted']

  # TODO: Make brand_domain_opt_outs an array column
  # TODO: Make page_url_opt_outs an array column
  # TODO: add auto_added boolean column
  DESCRIPTION_AUTO_ADD_FROM_AD_LINK = 'Added automatically via Ad Link'
  ACCOUNT_TYPES = ['instagram', 'facebook', 'youtube', 'tiktok', 'basic_instagram'].freeze

  APPEARANCES = [
    'Western/Americanize',
    'Korean Style',
    'Japanese',
    'Classy/Elegance',
    'Arty & Smart',
    'Sunny/Energetic',
    'Sweet & Charming',
    'Sexy/Curvy',
    'Sporty/Athletic',
    'Vintage/Retro',
    'Next Door Neighbor',
    'Minimalism',
    'Voluptuous',
    'Muscular/Fit',
    'Chubby/Plus Size',
  ].freeze

  BLACKLISTED_AD_LINK_HOSTNAMES = [
    '.*.googleusercontent.com',
    '.*.translate.goog',
    'content',
    'file',
    'http',
  ].freeze

  belongs_to :affiliate_prospect, inverse_of: :site_info, optional: true

  has_many :site_info_categories, inverse_of: :site_info, dependent: :destroy
  has_many :categories, through: :site_info_categories
  has_many :unique_view_stats, inverse_of: :site_info, dependent: :destroy
  has_many :affiliate_offers, inverse_of: :site_info, dependent: :nullify

  has_one :site_info_tag, inverse_of: :site_info,  autosave: true, dependent: :destroy
  has_one :media_category, through: :site_info_tag

  belongs_to_affiliate touch: true

  validates :url, presence: true
  # affiliate validation
  validates :url, uniqueness: { scope: :affiliate_id, case_sensitive: false }, if: -> { affiliate_id.present? }
  # admin validation in affiliate prospect
  validates :url, uniqueness: { case_sensitive: false }, if: -> { affiliate_id.blank? }
  validates :account_type, inclusion: { in: ACCOUNT_TYPES, allow_blank: true }
  validates :media_category, presence: true, if: :new_record?
  validates :affiliate, presence: true, if: -> { affiliate_prospect.blank? }
  validates :affiliate_prospect, presence: true, if: -> { affiliate.blank? }
  validate :validate_blacklisted_url
  validate :appearance_must_be_valid

  before_validation :normalize_url
  before_save :set_prospect_live
  before_create :set_defaults
  before_save :adjust_values
  after_save :update_url_to_affiliate_keywords

  # TODO: Delete
  define_constant_methods(STATUSES, :status)
  define_constant_methods(ACCOUNT_TYPES, :account_type)

  # TODO: Delete
  default_scope { active }

  scope_by_affiliate
  scope :connected, -> { where(error_details: nil).where.not(account_id: nil).where.not(account_type: nil).where.not(access_token: nil) }

  scope :with_appearances, -> (*args) {
    appearances = [args].flatten
    if appearances.present?
      conditions = appearances.flatten.map do |arg|
        <<-SQL.squish
          JSON_CONTAINS(appearances, '\"#{arg}\"')
        SQL
      end

      where(conditions.join(' OR '))
    end
  }

  def self.blacklisted?(hostname)
    return false if hostname.blank?

    BLACKLISTED_AD_LINK_HOSTNAMES.each do |item|
      r = Regexp.new(item)
      return true if hostname.match(r)
    end

    false
  end

  def self.to_unique_visit_per_day(value)
    return value unless value.is_a?(Integer)

    if value <= 1_000
      '0 - 1000'
    elsif value <= 10_000
      '1001 - 10,000'
    elsif value <= 100_000
      '10,001 - 100,000'
    elsif value <= 500_000
      '100,001 - 500,000'
    elsif value <= 1_000_000
      '500,001 - 1 Million'
    elsif value > 1_000_000
      '1 Million +'
    end
  end

  def media_category_id=(value)
    tag = AffiliateTag.find_by_id(value)
    self.media_category = tag
    @media_category_id = tag&.id
  end

  def media_category_id
    @media_category_id ||= media_category&.id
  end

  def blacklisted?
    hostname = DotOne::Utils::Url.host_name_without_www(url)
    SiteInfo.blacklisted?(hostname)
  end

  def auto_added?
    description == DESCRIPTION_AUTO_ADD_FROM_AD_LINK
  end

  def integrated?
    account_type? && account_id? && access_token?
  end

  def connected?
    integrated? && error_details.blank?
  end

  def verified?
    return integrated? if integration_applicable?
    super
  end

  def impression_available?
    verified? && !integrated?
  end

  def ad_link_applicable?
    impression_available? || media_category&.ad_link_tag?
  end

  def integration_applicable?
    media_category&.integration_tag?
  end

  def destroy_if_applicable!
    if affiliate_prospect.present?
      update(affiliate_id: nil)
    else
      destroy
    end
  end

  def brand_domain_opt_outs
    to_url_array(self[:brand_domain_opt_outs])
  end

  def brand_domain_opt_outs=(value)
    super(to_url_string(value))
  end

  def page_url_opt_outs
    to_url_array(self[:page_url_opt_outs])
  end

  def page_url_opt_outs=(value)
    super(to_url_string(value))
  end

  def unique_visit_per_day=(value)
    super(SiteInfo.to_unique_visit_per_day(value))
  end

  def impressions
    return unless impression_available?

    @impressions ||= begin
      stats = unique_view_stats.last_30_days.group(:date).sum(:count)

      (30.days.ago.to_date..Date.today).to_h do |date|
        [date.to_s, stats[date] || 0]
      end
    end
  end

  def unique_visit_per_month
    return super unless impression_available?

    impressions.values.sum
  end

  def access_token=(value)
    if value.present?
      super(encrypter.encrypt_and_sign(value))
    else
      super(nil)
    end
  end

  def access_token
    encrypter.decrypt_and_verify(super) rescue nil
  end

  def hostname
    DotOne::Utils::Url.host_name_without_www(url)
  end

  def live_metrics(options = {})
    return unless (integrated? && options[:retry]) || connected?

    params = {
      'id' => account_id,
      'access_token' => access_token,
    }

    fetcher = case account_type
    when SiteInfo.account_type_facebook
      OmniAuth::Fetcher::Facebook::Page.new(params)
    when SiteInfo.account_type_instagram
      OmniAuth::Fetcher::Facebook::Page::Instagram.new(params)
    when SiteInfo.account_type_tiktok
      OmniAuth::Fetcher::Tiktok.new(refresh_token: access_token)
    when SiteInfo.account_type_youtube
      auth = OmniAuth::Fetcher::Youtube::Token.new(refresh_token: access_token).auth
      OmniAuth::Fetcher::Youtube::Channel.new(account_id, auth)
    when SiteInfo.account_type_basic_instagram
      oauth = OmniAuth::Strategies::Instagram.new(nil)
      oauth.build_refresh_token(access_token)
      oauth
    end

    return unless fetcher

    fetcher.site_info_metrics
  end

  def refresh_metrics(options = {})
    return unless (metrics = live_metrics(options))

    update(metrics.merge(metrics_last_updated_at: Time.now))
  rescue OmniAuth::Fetcher::Error::TokenError => e
    update(error_details: e.message)
  end

  private

  def set_prospect_live
    return if affiliate_prospect_id.present?

    affiliate_prospect = AffiliateProspect.joins(:site_info).find_by(site_infos: { url: url }, affiliate_id: nil)
    return unless affiliate_prospect

    affiliate_prospect.update(affiliate: affiliate)
    self.affiliate_prospect = affiliate_prospect
  end

  def adjust_values
    self.error_details = nil if access_token_changed?
    # self.ad_link_enabled = true unless ad_link_applicable?
    # self.ad_link_enabled = false if ad_link_applicable? && affiliate&.ad_link_terms_accepted_at.blank?
  end

  def update_url_to_affiliate_keywords
    save_url_as_keywords(url_was, url)
  end

  def encrypter
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
  end

  def to_url_array(value)
    value.to_s.split("\n")
  end

  def to_url_string(value)
    return value unless value.is_a?(Array)

    return unless value.is_a?(Array)

    value.reject(&:blank?).join("\n")
  end

  def set_defaults
    self.status ||= SiteInfo.status_active
  end

  def normalize_url
    return if url.blank?

    self.url = "https://#{url}" unless url.match(/\Ahttp(s)?:\/\//)

    uri = URI.parse(url)

    uri.scheme = 'https' unless uri.scheme == 'https'
    uri.path = uri.path.chop if uri.path.end_with?('/')

    self.url = uri.to_s
  rescue URI::InvalidURIError
    errors.add(:url, :url_exist)
  end

  def validate_blacklisted_url
    return unless blacklisted?

    errors.add(:url, :url_blacklisted)
  end

  def appearance_must_be_valid
    return unless appearances.present? && !appearances.all? { |appearance| APPEARANCES.include?(appearance) }

    errors.add(:appearances, :inclusion)
  end
end
