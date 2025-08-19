require 'socket'
require 'sanitize'
require 'rubygems'

class Network < DatabaseRecords::PrimaryRecord
  include AffiliateLoggable
  include AffiliateTaggable
  include Arrayable
  include Authenticatable
  include BecomeChatbotUser
  include BecomeChatter
  include BillingRegioned
  include Chargeable
  include ConstantProcessor
  include DateRangeable
  include Forexable
  include HasKeywords
  include HasUniqueStat
  include HasUniqueToken
  include LocalTimeZone
  include ModelCacheable
  include NameHelper
  include PurgeableFile
  include Roleable
  include Scopeable
  include Snippetable
  include Traceable
  include DotOne::I18n
  include NetworkHelpers::Downloadable
  include NetworkHelpers::EsSearch
  include Relations::AffiliateStatAssociated
  include Relations::CampaignAssociated
  include Relations::ChannelAssociated
  include Relations::CountryAssociated
  include Relations::CurrencyAssociated
  include Relations::HasApiKeys
  include Relations::HasCategoryGroups
  include Relations::HasClientApis
  include Relations::HasContactLists
  include Relations::HasCrmInfos
  include Relations::HasDownloads
  include Relations::HasUploads
  include Relations::LanguageAssociated
  include Relations::TimeZoneAssociated
  include Tokens::Tokenable

  self.primary_key = :id

  PAYMENT_TERMS = ['Prepay', 'Net Term', 'Net Term With Tax'].freeze
  STATUSES = ['Active', 'Paused', 'Suspended', 'Pending', 'New'].freeze
  SUBSCRIPTIONS = ['Regular', 'Pro', 'Partial Pro'].freeze
  SALES_PIPELINES = {
    'New Lead' => 'New',
    'Qualified Lead' => 'New',
    'Initial Contact' => 'Pending',
    'Follow-up Contact' => 'Pending',
    'Presentation & Demo' => 'Pending',
    'Evaluate & Negotiate' => 'Pending',
    'Contract Signed' => 'Pending',
    'Deal Completed' => 'Active',
    'Not Interested' => 'Pending',
    'Unqualified Lead' => 'Suspended',
  }.freeze
  GRADES = ['a', 'b', 'c', 'd'].freeze

  attr_accessor :do_notify_status_change, :skip_validation
  attr_writer :current_balance, :pending_payout, :published_payout

  alias_attribute :email, :contact_email

  belongs_to :billing_currency, class_name: 'Currency'
  belongs_to :recruiter, class_name: 'AffiliateUser', inverse_of: :recruited_networks
  belongs_to :partner_app, inverse_of: :network

  has_many_affiliate_stats
  has_many :attachments, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :bot_stats, inverse_of: :network
  has_many :offers, inverse_of: :network, dependent: :nullify
  has_many :orders, inverse_of: :network, dependent: :nullify
  has_many :network_offers, inverse_of: :network, dependent: :nullify
  has_many :offer_variants, through: :offers
  has_many :image_creatives, through: :offer_variants
  has_many :text_creatives, through: :offer_variants
  has_many :advertiser_balances, inverse_of: :network, dependent: :nullify
  has_many :advertiser_cats, inverse_of: :advertiser, dependent: :destroy
  has_many_category_groups through: :advertiser_cats
  has_many :easy_store_setups, inverse_of: :network, dependent: :nullify
  has_many :shopify_setups, inverse_of: :network, dependent: :nullify
  has_many :network_assignments, class_name: 'AffiliateAssignment', inverse_of: :network, dependent: :destroy
  has_many :affiliate_users, through: :network_assignments
  has_many :vtm_channels, inverse_of: :network, dependent: :destroy
  has_many :mkt_sites, inverse_of: :network, dependent: :destroy
  has_many :quicklinks, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :affiliates, through: :offers

  has_one :current_balance_item, -> { part_of_balance.recent }, class_name: 'AdvertiserBalance'
  has_one :order_api, -> { order_api }, class_name: 'ClientApi', as: :owner, inverse_of: :owner, dependent: :destroy
  # TODO:: deprecate
  has_one :avatar, -> { avatar.order(created_at: :desc) }, class_name: 'Image', as: :owner, inverse_of: :owner, dependent: :destroy

  validates :contact_email, presence: true
  validates :contact_email, format: { with: REGEX_EMAIL }, if: :new_record?
  validates :contact_email, uniqueness: { scope: :status, case_sensitive: false }, if: :active?
  validates :name, :contact_name, :contact_phone, :company_url, :country_id, presence: true, if: -> { new_record? && !skip_validation }
  validates :company_url, :contact_name, :contact_phone, :contact_title, :iso_2_country_code, :locale_code, :name, presence: true, on: :create_via_api
  validates :status, inclusion: { in: STATUSES }
  validates :sales_pipeline, inclusion: { in: SALES_PIPELINES.keys }
  validates :subscription, inclusion: { in: SUBSCRIPTIONS }
  validates :grade, inclusion: { in: GRADES, allow_blank: true }

  before_validation :set_defaults
  before_save :set_status_from_pipeline
  before_save :assign_company_domain_name_to_keywords
  after_commit :notify_status_change, if: :do_notify_status_change

  # setup specs:
  #  {  :api => {
  #       :module => "the module",
  #       :xml => {
  #         :url => "the url",
  #         :body => "the xml content",
  #         :regex_accept => "regex for when the lead is accepted"
  #      }
  #    }
  #  }
  serialize :setup

  set_token_prefix :adv
  set_forexable_attributes :current_balance
  set_local_time_attributes :profile_updated_at, :note_updated_at, :recruited_at, :created_at, :published_date
  set_array_attributes :ip_address_white_listed, :dns_white_listed, :blacklisted_subids, :blacklisted_referer_domain
  set_purgeable_file_attributes :avatar_cdn_url

  trace_ignorable :unique_token

  define_constant_methods STATUSES, :status
  define_constant_methods SUBSCRIPTIONS, :subscription
  define_constant_methods PAYMENT_TERMS, :payment_term
  define_constant_methods SALES_PIPELINES.keys, :sales_pipeline

  define_unique_stat key: :adv

  authenticatable(status: Network.status_active)

  scope_by_recruiter

  scope :with_part_of_balance, -> {
    joins(:advertiser_balances).where(advertiser_balances: AdvertiserBalance.part_of_balance).distinct
  }

  scope :considered_pending, -> { where(status: statuses_considered_pending) }
  scope :considered_valid, -> { where(status: statuses_considered_valid) }
  scope :recent, -> { order(created_at: :desc) }
  scope :stat_summary_notification_on, -> { where('JSON_EXTRACT(notification, "$.stat_summary") = true') }

  def self.s2s_params_options
    [
      ['Transaction ID', 'server_subid'],
      ['Order Number', 'order'],
      ['Order Total', 'order_total'],
      ['Commission', 'revenue'],
    ]
  end

  def self.with_positive_remaining_balance
    with_part_of_balance.select { |n| n.remaining_balance >= 0 }
  end

  def self.with_negative_remaining_balance
    with_part_of_balance.select { |n| n.remaining_balance < 0 }
  end

  def self.statuses_considered_pending
    [status_new, status_pending]
  end

  def self.statuses_considered_valid
    [status_new, status_pending, status_active]
  end

  def name
    self[:name].presence || contact_name.presence || contact_email.to_s.match(/(\w+)@.+/).try(:[], 1)
  end

  def billing_currency
    super || Currency.platform
  end

  def original_currency
    billing_currency.code
  end

  # OpenStruct is used to allow the use of dot notation.
  def api
    require 'ostruct'
    begin
      OpenStruct.new setup['api']
    rescue StandardError
    end
  end

  def has_api?
    api.present?
  end

  def has_product_feed?
    ClientApi.product_api.active.where(owner_type: 'Offer', owner_id: offer_ids).any?
  end

  def considered_pending?
    Network.statuses_considered_pending.include?(status)
  end

  def stat_summary_notification_on?
    !!notification&.dig('stat_summary')
  end

  def payment_term_days
    return if prepay?
    super
  end

  def authorized_ips_from_dns
    @authorized_ips_from_dns ||= dns_white_listed_array.map { |dns| IPSocket.getaddress(dns) }
  end

  def current_balance
    @current_balance ||= current_balance_item&.final_balance.to_f
  end

  def pending_payout
    @pending_payout ||= Stat.with_networks(id).network_pending_payouts[id]&.pending_true_pay.to_f
  end

  def published_payout
    @published_payout ||= Stat.with_networks(id).network_published_payouts[id]&.published_true_pay.to_f
  end

  def remaining_balance
    @remaining_balance ||= current_balance - pending_payout - published_payout
  end

  def download_and_send_gdpr_order_csv(exec_sql, options = {})
    options.merge!(notes: 'Generated via GDPR request')
    download = Order.csv_download(exec_sql, Order.default_columns, options)
    notify_gdpr_data_ready(download.file_url)
  end

  def notify_status_suspended_due_to_gdpr
    notify_status_change
    AdvertiserMailer.status_suspended_due_to_gdpr(self, cc: true).deliver_later if affiliate_users.any?
  end

  def notify_gdpr_data_ready(data_url)
    AdvertiserMailer.gdpr_data_ready(self, data_url, cc: true).deliver_later
  end

  def notify_status_change
    return AdvertiserMailer.status_suspended(self, cc: true).deliver_later if suspended?
    return AdvertiserMailer.status_active(self, cc: true).deliver_later if active?
  end

  def touch(column = :profile_updated_at)
    to_touch = [String, Symbol].include?(column.class) ? column : :profile_updated_at
    super(to_touch)
  end

  def brands
    super || []
  end

  def s2s_params
    (setup&.dig(:s2s_params).to_h || {}).with_indifferent_access
  end

  def s2s_params=(value)
    self.setup = {
      **setup.to_h,
      s2s_params: value.to_h.reject { |_, v| v.blank? },
    }
  end

  def request_api_key
    s = DotOne::Utils::ApiKey.new(network_id: id)
    s.encrypt
  end

  private

  def set_defaults
    self.status ||= Network.status_new
    self.sales_pipeline ||= Network.sales_pipeline_new_lead
    self.active_at = Time.now if status_changed? && active? && active_at.blank?
  end

  def set_status_from_pipeline
    return if status_changed? || !considered_pending? || !sales_pipeline_changed?

    self.status = SALES_PIPELINES[sales_pipeline]
  end

  def assign_company_domain_name_to_keywords
    old_url = company_url_was&.strip
    new_url = company_url&.strip

    self_keywords = keywords&.split(',')&.map(&:strip) || []

    if old_url.present?
      begin
        old_domains = [
          DotOne::Utils::Url.domain_name(old_url),
          DotOne::Utils::Url.domain_name_without_tld(old_url),
        ]
        self_keywords = self_keywords.reject { |x| old_domains.include?(x) }
      rescue PublicSuffix::DomainNotAllowed => e
        self_keywords = self_keywords.reject { |x| [old_url].include?(x) }
      end
    end

    if new_url.present?
      begin
        self_keywords += [
          DotOne::Utils::Url.domain_name(new_url),
          DotOne::Utils::Url.domain_name_without_tld(new_url),
        ]
      rescue PublicSuffix::DomainNotAllowed => e
        self_keywords << new_url
      end
    end

    self.keywords = self_keywords.compact.uniq.join(', ')
  end

  # For the time being during advertiser registration, no
  # login account is created. Our internal team will create
  # the login account for them after they contact, discuss
  # and clarify the contract to bring the advertiser on board our network.
  def skip_password_validation?
    true
  end
end
