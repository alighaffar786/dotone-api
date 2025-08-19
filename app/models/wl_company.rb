require 'net/http'
require 'uri'
require 'request_store'
require 'wepay'
require 'pg'

class WlCompany < DatabaseRecords::SecondaryRecord
  include DynamicTranslatable
  include ModelCacheable
  include Userable
  include Relations::CurrencyAssociated
  include Relations::LanguageAssociated
  include Tokens::Tokenable

    ####################### SETUP LIST ##########################
  # Any configuration for each client's app will be managed here.
  # Each constant should be clearly declared to make sure
  # we know what it is.
  #############################################################

  # flag to show/hide pending columns
  SETUP_KEYS_AFFILIATE_PENDING_COLUMNS = :affiliate_pending_columns
  # list of country available for selection on affiliate prospect form.
  SETUP_KEYS_AFFILIATE_PROSPECT_COUNTRY_RESIDENCY_LIST = :affiliate_prospect_country_residency_list
  # flag to redirect affiliate prospect after email verification.
  SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_URL = :affiliate_prospect_email_verification_url
  # flag to redirect affiliate prospect after email verification success.
  SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_SUCCESS_URL = :affiliate_prospect_email_verification_success_url
  # flag to redirect affiliate prospect after email verification failure.
  SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_FAILURE_URL = :affiliate_prospect_email_verification_failure_url

  SETUP_KEYS_AFFILIATE_PRIVACY_POLICY_URL = :affiliate_privacy_policy_url

  # flag to redirect advertiser prospect after email verification.
  SETUP_KEYS_ADVERTISER_PROSPECT_EMAIL_VERIFICATION_URL = :advertiser_prospect_email_verification_url
  # flag to show/hide rejected columns
  SETUP_KEYS_AFFILIATE_REJECTED_COLUMNS = :affiliate_rejected_columns
  # flag to assign affiliate id to test
  SETUP_KEYS_AFFILIATE_ID_FOR_TEST = :affiliate_id_for_test
  # flag to assign affiliate id on missing credits (credits that affiliates are unknown)
  SETUP_KEYS_AFFILIATE_ID_FOR_MISSING_CREDIT = :affiliate_id_for_missing_credit

  SETUP_KEYS_NETWORK_ID_FOR_TEST = :network_id_for_test

  # tracking URL has https protocol
  SETUP_KEYS_HTTPS = :https

  # Offer assigned to be a catch-all for NSA inventories.
  # This offer will be used when no other offer is eligible
  # to serve the ad request
  SETUP_KEYS_CATCH_ALL_OFFER_ID_FOR_NSA = :catch_all_offer_id_for_nsa

  # Company Names for affiliate payments:
  SETUP_KEYS_COMPANY_NAME_FOR_TW_COMPANY = :company_name_for_tw_company
  SETUP_KEYS_COMPANY_NAME_FOR_TW_INDIVIDUAL = :company_name_for_tw_individual
  SETUP_KEYS_COMPANY_NAME_FOR_US_COMPANY = :company_name_for_us_company
  SETUP_KEYS_COMPANY_NAME_FOR_US_INDIVIDUAL = :company_name_for_us_individual
  SETUP_KEYS_COMPANY_NAME_FOR_INTL_COMPANY = :company_name_for_intl_company
  SETUP_KEYS_COMPANY_NAME_FOR_INTL_INDIVIDUAL = :company_name_for_intl_individual

  # Panel has https protocol access
  SETUP_KEYS_PANEL_HTTPS = :panel_https

  # flag to let the corresponding personnel know that new campaign (affiliate applying for offer) is created
  SETUP_KEYS_NEW_CAMPAIGN_NOTIFICATION = :new_campaign_notification
  # url to redirect to when affiliate inactive
  # content of the custom affiliate's terms and conditions that the client has.
  SETUP_KEYS_AFFILIATE_TERMS_AND_CONDITIONS = :affiliate_terms_and_conditions
  # marketing tools (true or false) - to show all the Marketing Module
  SETUP_KEYS_MKT = :mkt
  # channel name where traffic driven by the affiliates will be recorded under.
  SETUP_KEYS_NETWORK_CHANNEL_NAME = :network_channel_name
  # suppression feature turned on or of (true or false)
  SETUP_KEYS_SUPPRESSION = :suppression
  # flag to use redshift database
  SETUP_KEYS_USE_REDSHIFT = :use_redshift

  # panel color setup
  SETUP_KEYS_OWNER_PANEL_COLOR = :owner_panel_color
  SETUP_KEYS_TEAM_PANEL_COLOR = :team_panel_color
  SETUP_KEYS_AFFILIATE_PANEL_COLOR = :affiliate_panel_color
  SETUP_KEYS_ADVERTISER_PANEL_COLOR = :advertiser_panel_color
  SETUP_KEYS_CUSTOM_CSS = :custom_css

  SETUP_FACEBOOK_ACCESS_TOKEN = :facebook_access_token
  SETUP_FACEBOOK_INSTAGRAM_ID = :facebook_instagram_id

  SETUP_DB_STATE = :db_state

  # subdomain for all the domain
  attr_accessor :panel_name

  # to accept skin maps in array form.
  # example: "skin"=>[{"hostname"=>"converly.com", "folder"=>"converly.com"}, {"hostname"=>"", "folder"=>""}]
  attr_accessor :skin

  # NOTE: there is -company_general_email- email token
  alias_attribute :general_email, :general_contact_email

  belongs_to :user, inverse_of: :wl_company, dependent: :destroy

  has_many :skin_maps, inverse_of: :wl_company, dependent: :destroy
  has_many :alternative_domains, inverse_of: :wl_company, dependent: :destroy

  accepts_nested_attributes_for :user, :skin_maps

  validates :domain_name, uniqueness: true, allow_blank: true

  mount_uploader :favicon_url, FaviconUploader

  serialize :setup, Hash
  set_token_prefix :company
  set_dynamic_translatable_attributes(affiliate_terms: :html)

  before_save :initialize_setup_to_hash

  scope :like, -> (*args) {
    if args.present? && args[0].present?
      where('wl_companies.id LIKE ? OR wl_companies.name LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?',
        "%#{args[0]}%", "%#{args[0]}%", "%#{args[0]}%", "%#{args[0]}%")
    end
  }

  def self.setup_key_options
    [
      SETUP_KEYS_AFFILIATE_PENDING_COLUMNS,
      SETUP_KEYS_AFFILIATE_PROSPECT_COUNTRY_RESIDENCY_LIST,
      SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_URL,
      SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_SUCCESS_URL,
      SETUP_KEYS_AFFILIATE_PROSPECT_EMAIL_VERIFICATION_FAILURE_URL,
      SETUP_KEYS_AFFILIATE_PRIVACY_POLICY_URL,
      SETUP_KEYS_ADVERTISER_PROSPECT_EMAIL_VERIFICATION_URL,
      SETUP_KEYS_AFFILIATE_REJECTED_COLUMNS,
      SETUP_KEYS_AFFILIATE_ID_FOR_TEST,
      SETUP_KEYS_AFFILIATE_ID_FOR_MISSING_CREDIT,
      SETUP_KEYS_CATCH_ALL_OFFER_ID_FOR_NSA,
      SETUP_KEYS_COMPANY_NAME_FOR_TW_COMPANY,
      SETUP_KEYS_COMPANY_NAME_FOR_TW_INDIVIDUAL,
      SETUP_KEYS_COMPANY_NAME_FOR_US_COMPANY,
      SETUP_KEYS_COMPANY_NAME_FOR_US_INDIVIDUAL,
      SETUP_KEYS_COMPANY_NAME_FOR_INTL_COMPANY,
      SETUP_KEYS_COMPANY_NAME_FOR_INTL_INDIVIDUAL,
      SETUP_KEYS_HTTPS,
      SETUP_KEYS_PANEL_HTTPS,
      SETUP_KEYS_NETWORK_ID_FOR_TEST,
      SETUP_KEYS_NEW_CAMPAIGN_NOTIFICATION,
      SETUP_KEYS_AFFILIATE_TERMS_AND_CONDITIONS,
      SETUP_KEYS_MKT,
      SETUP_KEYS_NETWORK_CHANNEL_NAME,
      SETUP_KEYS_SUPPRESSION,
      SETUP_KEYS_USE_REDSHIFT,
      SETUP_KEYS_OWNER_PANEL_COLOR,
      SETUP_KEYS_TEAM_PANEL_COLOR,
      SETUP_KEYS_AFFILIATE_PANEL_COLOR,
      SETUP_KEYS_ADVERTISER_PANEL_COLOR,
      SETUP_KEYS_CUSTOM_CSS,
      SETUP_FACEBOOK_ACCESS_TOKEN,
      SETUP_FACEBOOK_INSTAGRAM_ID,
      SETUP_DB_STATE,
    ]
  end

  def self.default
    @default ||= begin
      key = WlCompany.cache_key(:find, 8)
      Rails.env.production? ? Rails.cache.fetch(key) { find(8) } : first
    end
  end

  def self.default=(wl)
    @default = wl
  end

  def id_with_name
    "(#{id})-#{name}"
  end

  ##
  # Setter to make sure any setup key not present from client will not
  # reset the existing setup key value in the database.
  def setup=(setup_hash)
    setup_hash = HashWithIndifferentAccess.new(setup_hash)
    WlCompany.setup_key_options.each do |key|
      setup[key] = setup_hash[key] if setup_hash.has_key?(key)
    end
  end

  def initialize_setup_to_hash
    self.setup = if setup.nil?
      {}
    else
      setup.symbolize_keys
    end
  end

  # builder for the custom css specified by the client.
  def custom_css
    to_return = []
    to_return << setup[:custom_css] if setup.present?
    to_return.present? ? to_return.join(' ') : nil
  end

  def country_code
    language.country.iso_2_country_code.downcase rescue nil
  end

  def time_zone
    TimeZone.cache_find(26) || TimeZone.first
  end

  def cached_time_zone
    time_zone
  end

  def switch_role
    user = self.user
    user.roles = user.roles == Role::NAME_MEDIA_BUYER ? [Role.find_by_name(Role::NAME_NETWORK_OWNER)] : [Role.find_by_name(Role::NAME_MEDIA_BUYER)]
    user.save
  end

  # Determine the protocol used for this company
  # to make sure any built URL is using secured connection
  # when available
  def panel_protocol
    setup[SETUP_KEYS_PANEL_HTTPS] == true ? 'https' : 'http'
  end

  def logo_url
    "#{DotOne::Setup.cdn_url}/logos/logo_affiliatesone_blue.png"
  end

  def refresh_facebook_access_token
    return if (token = setup[:facebook_access_token]).blank?

    token = Koala::Facebook::OAuth.new.exchange_access_token(token)

    setup[:facebook_access_token] = token
    save

    token
  end

  def db_on?
    [nil, 'ON'].include?(setup[SETUP_DB_STATE])
  end

  def db_state=(is_on)
    self.setup[SETUP_DB_STATE] = is_on ? 'ON' : 'OFF'
    save
  end
end
