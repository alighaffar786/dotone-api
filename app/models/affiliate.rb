require 'tempfile'

class Affiliate < DatabaseRecords::PrimaryRecord
  include AffHashable
  include AffiliateLoggable
  include AffiliateTaggable
  include Authenticatable
  include BecomeChatbotUser
  include BecomeChatter
  include ConstantProcessor
  include DateRangeable
  include HasKeywords
  include HasUniqueStat
  include HasUniqueToken
  include LocalTimeZone
  include Maskable
  include ModelCacheable
  include NameHelper
  include PurgeableFile
  include Roleable
  include Scopeable
  include StaticTranslatable
  include Traceable
  include AffiliateHelpers::Downloadable
  include AffiliateHelpers::EsSearch
  include AffiliateHelpers::Oauth
  include AffiliateHelpers::Query
  include DotOne::I18n
  include Relations::AffiliateStatAssociated
  include Relations::CampaignAssociated
  include Relations::ChannelAssociated
  include Relations::CurrencyAssociated
  include Relations::HasAccessTokens
  include Relations::HasApiKeys
  include Relations::HasClientApis
  include Relations::HasContactLists
  include Relations::HasCrmInfos
  include Relations::HasDownloads
  include Relations::LanguageAssociated
  include Relations::TimeZoneAssociated
  include Tokens::Tokenable

  self.primary_key = :id

  STATUSES = ['New', 'Active', 'Pending', 'Paused', 'Suspended'].freeze
  BUSINESS_ENTITY_TYPES = ['Individual', 'Company'].freeze

  PAYMENT_TERM_ONCE_A_MONTH = 'Once a month'.freeze
  PAYMENT_TERM_TWICE_A_MONTH = 'Twice a month'.freeze

  SOURCES = ['Direct', 'Marketplace'].freeze
  LABELS = ['Superb', 'Excellent', 'Above Average', 'Average', 'Below Average', 'Poor', 'Black List'].freeze

  SETUP_KEYS_OFFER_STATUS_NOTIFICATION = :offer_status_notification  # offer status notification on or off (true or false)
  SETUP_KEYS_OFFER_APPLICATION_APPROVAL = :offer_application_approval # offer application approval on or off (true or false)

  GENDERS = ['Woman', 'Man', 'Non-Binary', 'Transgender', 'Prefer Not to Say'].freeze

  attr_accessor :kvp_hash, :ad_link_terms_accepted, :oauth_image_url

  belongs_to :referrer, class_name: 'Affiliate', inverse_of: :referrals
  belongs_to :recruiter, class_name: 'AffiliateUser', inverse_of: :affiliates

  has_many_affiliate_stats
  has_many :bot_stats, inverse_of: :affiliate
  has_many :affiliate_offers, -> { includes(:offer) }, inverse_of: :affiliate, dependent: :destroy
  has_many :affiliate_payments, inverse_of: :affiliate, dependent: :nullify
  has_many :affiliate_assignments, -> { ordered }, inverse_of: :affiliate, dependent: :destroy
  has_many :vtm_channels, inverse_of: :affiliate, dependent: :destroy
  has_many :vtm_campaigns, inverse_of: :affiliate, dependent: :destroy
  has_many :expertise_maps, inverse_of: :affiliate, dependent: :destroy
  has_many :orders, inverse_of: :affiliate, dependent: :nullify
  has_many :quicklinks, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :ad_slots, inverse_of: :affiliate, dependent: :nullify
  has_many :ad_link_stats, inverse_of: :affiliate, dependent: :destroy
  has_many :active_affiliate_offers, -> { active }, class_name: 'AffiliateOffer'
  has_many :non_suspended_affiliate_offers, -> { non_suspended }, class_name: 'AffiliateOffer'
  has_many :referrals, foreign_key: :referrer_id, class_name: 'Affiliate', inverse_of: :referrer, dependent: :nullify
  has_many :attachments, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :documents, -> { documents }, class_name: 'Attachment', as: :owner, inverse_of: :owner
  has_many :affiliate_search_logs, inverse_of: :affiliate, dependent: :destroy
  has_many :missing_orders, inverse_of: :affiliate, dependent: :destroy
  has_many :unique_view_stats, inverse_of: :affiliate, dependent: :destroy
  has_many :mkt_sites, inverse_of: :affiliate, dependent: :destroy
  has_many :site_infos, inverse_of: :affiliate, dependent: :destroy

  has_one :affiliate_application, inverse_of: :affiliate, dependent: :destroy
  has_one :affiliate_address, inverse_of: :affiliate, dependent: :destroy
  has_one :affiliate_prospect, inverse_of: :affiliate
  # TODO: deprecate
  has_one :avatar, -> { avatar.order(created_at: :desc) }, class_name: 'Image', as: :owner, dependent: :destroy
  has_one :payment_info, -> { order(created_at: :desc) }, class_name: 'AffiliatePaymentInfo', inverse_of: :affiliate, validate: false, dependent: :destroy
  has_one :captured_conversion_api, -> { captured_conversion_api }, class_name: 'ClientApi', as: :owner, inverse_of: :owner, dependent: :destroy
  has_one :confirmed_conversion_api, -> { confirmed_conversion_api }, class_name: 'ClientApi', as: :owner, inverse_of: :owner, dependent: :destroy

  # through relations
  has_many :offers, through: :affiliate_offers
  has_many :conversion_steps, through: :affiliate_offers
  has_many :step_prices, through: :conversion_steps
  has_many :affiliate_users, through: :affiliate_assignments
  has_many :expertises, through: :expertise_maps
  has_many :active_offers, source: :offer, through: :active_affiliate_offers
  has_many :active_offer_variants, -> { active }, source: :default_offer_variant, through: :active_offers
  has_many :non_suspended_offers, source: :offer, through: :non_suspended_affiliate_offers
  has_many :non_suspended_offer_variants, -> { not_suspended }, source: :default_offer_variant, through: :non_suspended_offers
  has_many :group_tags, through: :owner_has_tags
  has_many :media_categories, -> { distinct }, through: :site_infos, source: :media_category

  has_one :country, through: :affiliate_address
  has_one :affiliate_offer_with_phone_number, -> { where.not(phone_number: nil).order(created_at: :desc) }, class_name: 'AffiliateOffer', inverse_of: :affiliate

  Attachment.document_type_names.each do |document_name|
    relation_name = ConstantProcessor.to_method_name(document_name)

    has_one relation_name, -> { send(relation_name).order(created_at: :desc) }, class_name: 'Attachment', as: :owner, autosave: true

    define_method "#{relation_name}_url" do
      send(relation_name)&.link_url
    end

    define_method "#{relation_name}_link=" do |value|
      return if value.blank?

      attachment = send(relation_name)
      attachment ||= send("build_#{relation_name}")
      attachment.link = value
    end
  end

  accepts_nested_attributes_for :affiliate_address, :affiliate_application, :payment_info

  validates :status, inclusion: { in: STATUSES }
  validates :email, presence: true, unless: :connected?
  validates :email, format: { with: REGEX_EMAIL }, if: :email?
  validates :email, uniqueness: { case_sensitive: false }, if: -> { email? and status == Affiliate.status_new }
  validates :email, uniqueness: { case_sensitive: false, scope: :status }, if: -> { email? and status != Affiliate.status_new }
  validates :first_name, length: { maximum: 20 }, allow_blank: true, if: :first_name_changed?
  validates :source, inclusion: { in: SOURCES }
  validates :traffic_quality_level, inclusion: { in: (0..5) }
  validates :label, inclusion: { in: LABELS, allow_blank: true }
  validates :gender, inclusion: { in: GENDERS, allow_blank: true }
  validates :facebook_id, :line_id, :google_id, uniqueness: true, allow_blank: true, if: :validate_social_id_uniqueness?
  validates :tax_filing_country, presence: true, if: :validate_tax_filing_country_presence?
  validates :ssn_ein, uniqueness: { scope: :tax_filing_country, allow_blank: true }, if: :validate_ssn_ein_uniqueness?
  # TODO:
  # validates :birthday, presence: true, on: :create

  validates_with AffiliateHelpers::Validator::MustBeOldEnough
  validates_with AffiliateHelpers::Validator::CanAssignRecruiterWhenNoConversion, on: :update, if: :recruiter_id_changed?
  validates_with AffiliateHelpers::Validator::CanAssignRecruiterWhenBlank, on: :update, if: :recruiter_id_changed?
  validates_with AffiliateHelpers::Validator::CannotBeBlacklistedEmailDomain, allow_blank: true

  before_validation :set_defaults

  before_save :track_status_change_timestamp, if: :status_changed?
  before_save :remove_ad_link_file_on_status_change, if: :status_changed?
  after_save :queue_update_referral_count
  after_save :upload_image_and_retrieve_url
  after_create :assign_to_prospect

  serialize :extra
  serialize :setup

  mount_uploader :ad_link_file, AdLinkJsUploader

  define_constant_methods STATUSES, :status
  define_constant_methods BUSINESS_ENTITY_TYPES, :business_entity
  define_constant_methods SOURCES, :source
  define_constant_methods GENDERS, :gender
  define_unique_stat key: :aff

  set_predefined_flag_attributes :messenger_id, :messenger_id_2, :messenger_service, :messenger_service_2, :cj_pid
  set_purgeable_file_attributes :avatar_cdn_url
  set_maskable_attributes :ssn_ein
  set_static_translatable_attributes :tax_filing_country, tax_filing_country: 'country.name'
  predefined_system_flag_attributes :top_offer_stats
  set_instance_cache_methods :site_infos, :aff_hash

  # Used to simplify address to manage payment delivery.
  # Often time, using the separated address 1, address 2, city, state,
  # zip code format will screw up the data since users will
  # enter same value on address 1 and 2. By combine it
  # as one field, it will make the field value simpler.
  set_predefined_flag_attributes :legal_resident_address

  set_token_prefix :aff
  set_local_time_attributes :last_request_at, :created_at, :referral_expired_at, :recruited_at,
    :ad_link_terms_accepted_at, :ad_link_activated_at, :ad_link_installed_at
  trace_ignorable :unique_token, :last_request_at, :crypted_password, :last_request_ip
  trace_has_one_includes :affiliate_application
  trace_has_many_includes :affiliate_offers, :conversion_steps, :step_prices

  scope_by_approval_method
  scope_by_country 'affiliate_addresses.country_id'
  scope_by_recruiter
  scope_by_affiliate :id

  authenticatable do |affiliate|
    raise DotOne::Errors::AccountError.new(nil, 'Account Not Found') unless affiliate.present?

    if (affiliate.active? || affiliate.pending?) && affiliate.email_verified
      affiliate
    elsif !affiliate.can_login?
      raise DotOne::Errors::AccountError.new(affiliate.id, 'Account Not Active', affiliate)
    elsif affiliate.email_verified != true
      raise DotOne::Errors::EmailNotVerifiedError.new(affiliate.email, nil, affiliate)
    end
  end

  scope :referrals_by_expiration_type, -> (state, threshold_local_time, time_zone = nil, referrer = nil) {
    referrals = referrer ? referrer.referrals : where.not(referrer_id: nil)

    return referrals if state == :any

    if [:active, :expired].include?(state) && threshold_local_time.present?
      date_range = [threshold_local_time, nil]
      date_range.reverse! if state == :expired

      referrals
        .between(*date_range, :referral_expired_at, time_zone, any: true)
        .order(created_at: :desc)
    else
      referrals
    end
  }

  scope :active_referrals, -> (*args) { referrals_by_expiration_type(:active, *args) }
  scope :expired_referrals, -> (*args) { referrals_by_expiration_type(:expired, *args) }
  scope :with_referrals, -> { where('referral_count > ?', 0) }

  scope :considered_pending, -> { where(status: statuses_considered_pending) }
  scope :considered_valid, -> { where(status: statuses_considered_valid) }

  scope :with_accept_terms, -> (arg) {
    joins(:affiliate_application).where(affiliate_applications: { accept_terms: BooleanHelper.truthy?(arg) })
  }

  def self.statuses_considered_pending
    [status_new, status_pending]
  end

  def self.statuses_considered_valid
    [status_new, status_pending, status_active]
  end

  def self.payment_terms
    [
      PAYMENT_TERM_ONCE_A_MONTH,
      PAYMENT_TERM_TWICE_A_MONTH,
    ]
  end

  ##
  # Get affiliate for any catch-all need.
  # Use this when an affiliate is needed but
  # one is not provided/available. Only use
  # this as last resort
  def self.catch_all
    affiliate_id = DotOne::Setup.missing_credit_affiliate_id
    Affiliate.cached_find(affiliate_id) || Affiliate.first
  end

  def self.delayed_bulk_update(entity_sql, update_params, _options = {})
    records = Affiliate.find_by_sql(entity_sql.to_s)

    if (affiliate_user_id = update_params.delete(:affiliate_user_id))
      set_new = affiliate_user_id[:set]
      delete = affiliate_user_id[:delete]

      AffiliateAssignment.where(affiliate_user_id: delete, affiliate_id: records.map(&:id)).destroy_all if delete.present?

      if set_new.present?
        records.each do |affiliate|
          AffiliateAssignment.create(affiliate_user_id: set_new, affiliate_id: affiliate.id)
        end
      end
    end

    return unless update_params.present?

    Affiliate.where(id: records.map(&:id)).update_all(update_params.merge(updated_at: Time.now))
  end

  def account_setup_finished=(value)
    return unless value && pending?

    self.status = Affiliate.status_active
  end

  def connected?
    facebook_id.present? || google_id.present? || line_id.present?
  end

  def considered_pending?
    Affiliate.statuses_considered_pending.include?(status)
  end

  def business_entity
    self[:business_entity].presence || Affiliate.business_entity_individual
  end

  def local_tax_filing?
    tax_filing_country == 'Taiwan'
  end

  def us_tax_filing?
    tax_filing_country == 'United States'
  end

  def tax_filing_country_id
    @tax_filing_country_id ||= Country.cached_find_by(name: tax_filing_country)&.id
  end

  def tax_filing_country_id=(value)
    @tax_filing_country_id = value
    self.tax_filing_country = Country.cached_find(value)&.name
  end

  def ad_link_terms_accepted=(value)
    return unless value

    self.ad_link_terms_accepted_at ||= Time.now
  end

  def accept_terms?
    !!affiliate_application&.accept_terms
  end

  def age_confirmed?
    !!affiliate_application&.age_confirmed
  end

  def notify_application_approval?
    flag = setup_for('offer_application_approval')
    flag.blank? || truthy?(flag)
  end

  def find_site_info_by_hostname(url)
    cached_site_infos.find { |site_info| DotOne::Utils::Url.host_match?(site_info.url, url) }
  end

  def previous_balance
    last_payment = affiliate_payments.where.not(balance: nil).order(paid_date: :desc).first

    {
      amount: last_payment&.balance.to_f,
      currency_code: last_payment&.preferred_currency || Currency.platform_code,
    }
  end

  def queue_update_affiliate_balance
    Affiliates::UpdateBalanceJob.perform_later(id)
  end

  def create_payment(start_date, end_date, paid_date, options = {})
    previous_amount = if options[:previous_balance].is_a?(BigDecimal)
      options[:previous_balance]
    else
      BigDecimal(options[:previous_balance].gsub(
        /[^\d.]/, ''
      ).to_f.to_s)
    end
    referral_bonus = if options[:referral_bonus].is_a?(BigDecimal)
      options[:referral_bonus]
    else
      BigDecimal(options[:referral_bonus].gsub(
        /[^\d.]/, ''
      ).to_f.to_s)
    end
    earnings = if options[:earnings].is_a?(BigDecimal) || options[:earnings].is_a?(Float)
      options[:earnings]
    else
      BigDecimal(options[:earnings].gsub(
        /[^\d.]/, ''
      ).to_f.to_s)
    end
    total_commissions = previous_amount + referral_bonus + earnings
    payment_type = options[:payment_type]

    # create affiliate payment start
    affiliate_payment = AffiliatePayment.new
    affiliate_payment.affiliate_id = id
    affiliate_payment.start_date = start_date
    affiliate_payment.end_date = end_date
    affiliate_payment.paid_date = paid_date
    affiliate_payment.previous_amount = previous_amount
    affiliate_payment.referral_amount = referral_bonus
    affiliate_payment.affiliate_amount = earnings
    affiliate_payment.payment_type = payment_type

    if options[:status].present? && options[:status] == AffiliatePayment.status_redeemable
      affiliate_payment.status = AffiliatePayment.status_redeemable
      affiliate_payment.balance = total_commissions
    else
      affiliate_payment.status = affiliate_payment_status(total_commissions)
      affiliate_payment.balance = total_commissions if affiliate_payment.status == AffiliatePayment.status_deferred
    end

    affiliate_payment.save ? affiliate_payment : affiliate_payment.errors
  end

  def affiliate_payment_status(total_commissions)
    if total_commissions >= BigDecimal('1000')
      AffiliatePayment.status_pending
    else
      AffiliatePayment.status_deferred
    end
  end

  def update_login_count
    Affiliates::UpdateLoginCountJob.perform_later(id)
  end

  def has_action?; end

  # key value pair
  def kvp
    (extra && extra['kvp']) || {}
  end

  # To handle dynamic info calls
  def method_missing(method, *args)
    if method.to_s =~ /^kvp_/
      key = method.to_s.gsub(/^kvp_/, '')
      val = nil

      kvp_tag = args && args[0]
      val = flag("#{key}_tag_#{kvp_tag}") if kvp_tag.present?

      val = flag(key) if val.blank?

      # split test data if present
      val = val.to_s.split(TOKEN_SPLIT)
      val = val&.sample&.strip

      return val
    end

    super
  end

  # return if no setup is blank. Otherwise, return the value from hash based on the key
  def setup_for(key)
    return if setup.blank?

    setup[key]
  end

  def phone_number
    affiliate_application&.phone_number
  end

  def phone_number_last_used
    @phone_number_last_used ||= affiliate_offer_with_phone_number&.phone_number
  end

  def company_name
    return unless company?

    affiliate_application.company_name
  end

  def full_name
    company_name.presence || nickname.presence || super
  end

  def preferred_currency_code
    info = payment_info

    return Currency.platform_code if info.blank?

    if info.preferred_currency.blank?
      Currency.platform_code
    else
      info.preferred_currency
    end
  end

  def notify_affiliate_offer_invite(affiliate_offer_ids)
    return if affiliate_offer_ids.blank?

    AffiliateMailer.campaign_invite(self, affiliate_offer_ids.uniq, cc: true).deliver_later
  end

  def notify_status_change
    return AffiliateMailer.status_suspended(self, cc: true).deliver_later if suspended?
    return AffiliateMailer.status_active(self, cc: true).deliver_later if active?
  end

  def generate_ad_link_file!
    file = Tempfile.new("adlink.client.#{id}.js")
    content = DotOne::ScriptGenerator.generate_ad_link_file_content(self)
    file.write(content)
    file.close
    self.ad_link_file = file
    save!
    file.unlink
    reload
  end

  def ad_link_code(options = {})
    DotOne::ScriptGenerator.generate_ad_link_script(ad_link_file_url, options)
  end

  def old_enough?
    return if birthday.blank?

    (Date.today - 18.years) >= birthday
  end

  def to_referral_tracking_url
    DotOne::Track::Routes.track_affiliate_referral_url(id: id)
  end

  def set_as_verified
    self.email_verified = true
    self.status = Affiliate.status_pending if status.blank? || new?
    self.affiliate_application ||= build_affiliate_application
    self.affiliate_application.status = AffiliateApplication.status_approved
  end

  def mark_as_verified!
    set_as_verified
    save!
  end

  def offer_status_notification_enabled?
    flag = setup_for('offer_status_notification')
    flag.blank? || truthy?(flag)
  end

  def top_offer_ids
    @top_offer_ids ||= system_flag_top_offer_stats&.map(&:first).to_a
  end

  def top_offers
    @top_offers ||= offers.network_offer.where(id: top_offer_ids).to_a
  end

  def can_login?
    active? || pending?
  end

  private

  def remove_ad_link_file_on_status_change
    return unless status == Affiliate.status_suspended && status_was != Affiliate.status_suspended

    if ad_link_file_url.present?
      DotOne::Aws::CloudFront.invalidate(["/#{ad_link_file.path}"])
    end

    remove_ad_link_file!
    self.ad_link_terms_accepted_at = nil
    self.ad_link_activated_at = nil
    self.ad_link_installed_at = nil
  end

  def assign_to_prospect
    return unless (existing_affiliate_prospect = AffiliateProspect.find_by(email: email, affiliate_id: nil))

    existing_affiliate_prospect.update(affiliate: self)
  end

  def queue_update_referral_count
    return unless referrer_ids = saved_changes[:referrer_id]

    Affiliates::UpdateReferralCountJob.perform_later(referrer_ids)
  end

  def set_defaults
    self.traffic_quality_level ||= 3
    self.payment_info ||= build_payment_info
    self.status ||= Affiliate.status_new
    self.currency_id ||= Currency.platform&.id
    self.payment_term ||= PAYMENT_TERM_ONCE_A_MONTH
    self.business_entity ||= Affiliate.business_entity_individual
    self.affiliate_application ||= build_affiliate_application
    self.affiliate_address ||= build_affiliate_address

    if referrer_id.present? && referral_expired_at.blank?
      current_time_zone = TimeZone.current
      local_create_time = current_time_zone.from_utc(created_at)
      expiration_time = (local_create_time + 1.year).end_of_month
      expiration_time = current_time_zone.to_utc(expiration_time)

      self.referral_expired_at = expiration_time
    end

    self.extra = {} if extra.blank?
    extra['kvp'] = {} if extra['kvp'].blank?
    kvp_to_apply = {}
    return unless kvp_hash.present?

    kvp_hash.each do |hash|
      kvp_to_apply[hash['key']] = hash['value'] if hash['key'].present? && hash['value'].present?
    end

    extra['kvp'] = kvp_to_apply
  end

  def track_status_change_timestamp
    return unless DotOne::Current.user.present?

    affiliate_logs.build(agent: DotOne::Current.user, notes: "Status changed to #{status}")
  end

  def upload_image_and_retrieve_url
    return if oauth_image_url.blank?

    file = URI.open(oauth_image_url)

    uploader = AvatarUploader.new(self)
    uploader.store!(file)

    update_column(:avatar_cdn_url, uploader.url)
  rescue
  end

  def validate_social_id_uniqueness?
    new_record? || facebook_id_changed? || line_id_changed? || google_id_changed?
  end

  def validate_ssn_ein_uniqueness?
    return false if company?

    new_record? || tax_filing_country_changed? || ssn_ein_changed?
  end

  def validate_tax_filing_country_presence?
    persisted? && ssn_ein.present? && (tax_filing_country_changed? || ssn_ein_changed?)
  end
end
