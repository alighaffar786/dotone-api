class EmailTemplate < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include DynamicTranslatable
  include DotOne::I18n
  include Tokens::Tokenized
  include EmailTemplateHelpers::Liquidify

  STATUSES = [
    'Draft',
    'Active',
    'Paused',
  ].freeze

  EMAIL_TYPE_NEWSLETTER_BLANK_TEMPLATE = 'Blank Template'
  EMAIL_TYPE_NEWSLETTER_OFFER_ANNOUCEMENT = 'Offer Announcement'

  EMAIL_TYPE_ADVERTISER_EMAIL_VERIFICATION = 'Advertiser Email Verification'
  EMAIL_TYPE_ADVERTISER_STATUS_PENDING = 'Advertiser Status Pending'
  EMAIL_TYPE_ADVERTISER_STATUS_ACTIVE = 'Advertiser Status Active'
  EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED = 'Advertiser Status Suspended'
  EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED_DUE_TO_GDPR = 'Advertiser Status Suspended Due To GDPR'
  EMAIL_TYPE_ADVERTISER_PASSWORD_RESET = 'Advertiser Password Reset'
  EMAIL_TYPE_ADVERTISER_GDPR_DATA_READY = 'Advertiser GDPR Data Ready'
  EMAIL_TYPE_ADVERTISER_MONTHLY_REPORT = 'Advertiser Monthly Report'

  EMAIL_TYPE_AFFILIATE_EMAIL_VERIFICATION = 'Affiliate Email Verification'
  EMAIL_TYPE_AFFILIATE_STATUS_ACTIVE = 'Affiliate Status Active'
  EMAIL_TYPE_AFFILIATE_STATUS_SUSPENDED = 'Affiliate Status Suspended'
  EMAIL_TYPE_AFFILIATE_PASSWORD_RESET = 'Affiliate Password Reset'

  EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_CONFIRMED = 'Affiliate Payment Info Confirmed'
  EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_INCOMPLETE = 'Affiliate Payment Info Incomplete'

  EMAIL_TYPE_NEW_LEAD_NOTIFICATION = 'New Lead Notification' # Deprecated
  EMAIL_TYPE_NEW_MISSING_ORDERS = 'New Missing Orders'

  EMAIL_TYPE_OFFER_PAUSED_IMMEDIATE = 'Offer Paused Immediate'
  EMAIL_TYPE_OFFER_PAUSED_XHOUR = 'Offer Paused X Hour'
  EMAIL_TYPE_OFFER_STATUS_CHANGE = 'Offer Status Change'

  EMAIL_TYPE_BANNER_CREATIVE_REJECTED = 'Banner Creative Rejected'

  EMAIL_TYPE_OFFER_CAP_DEPLETING = 'Offer Cap Depleting'
  EMAIL_TYPE_OFFER_CAP_DEPLETED = 'Offer Cap Depleted'

  EMAIL_TYPE_CAMPAIGN_PAUSED = 'Campaign Paused'
  EMAIL_TYPE_CAMPAIGN_APPROVED = 'Campaign Approved'
  EMAIL_TYPE_CAMPAIGN_REJECTED = 'Campaign Rejected'
  EMAIL_TYPE_CAMPAIGN_INVITE_ADLINK = 'Campaign Invite via Adlink'

  EMAIL_TYPE_EVENT_CAMPAIGN_SELECTED = 'Event Campaign Selected'
  EMAIL_TYPE_EVENT_CAMPAIGN_CHANGES_REQUIRED = 'Event Campaign Changes Required'
  EMAIL_TYPE_EVENT_CAMPAIGN_COMPLETED = 'Event Campaign Completed'
  EMAIL_TYPE_EVENT_CAMPAIGN_REJECTED = 'Event Campaign Rejected'

  EMAIL_TYPE_CAMPAIGN_CAP_DEPLETING = 'Campaign Cap Depleting'
  EMAIL_TYPE_CAMPAIGN_CAP_DEPLETED = 'Campaign Cap Depleted'

  EMAIL_TYPE_FEED_CREATIVE_REJECTED = 'Feed Creative Rejected'

  EMAIL_TYPE_MISSING_ORDER_CONFIRMING = 'Missing Order Forwarded to the Advertiser'
  EMAIL_TYPE_MISSING_ORDER_APPROVED = 'Missing Order Approved'
  EMAIL_TYPE_MISSING_ORDER_REJECTED = 'Missing Order Rejected'
  EMAIL_TYPE_MISSING_ORDER_REMINDER = 'Missing Order Advertiser Reminder'

  EMAIL_TYPE_ORDER_INQUIRY_CONFIRMING = 'Order Inquiry Forwarded to the Advertiser'
  EMAIL_TYPE_ORDER_INQUIRY_APPROVED = 'Order Inquiry Approved'
  EMAIL_TYPE_ORDER_INQUIRY_REJECTED = 'Order Inquiry Rejected'
  EMAIL_TYPE_ORDER_INQUIRY_REMINDER = 'Order Inquiry Advertiser Reminder'

  EMAIL_TYPE_WEEKLY_PERFORMANCE_REPORT = 'Weekly Performance Report'
  EMAIL_TYPE_CLAIMABLE_BALANCE_REPORT = 'Claimable Balance Report'

  belongs_to :owner, polymorphic: true, inverse_of: :email_templates
  belongs_to :newsletter, foreign_key: :owner_id

  has_many :email_opt_ins, inverse_of: :email_template, dependent: :destroy

  validates :email_type, presence: true, uniqueness: { scope: [:owner_type, :owner_id] }
  validates :status, :content, :subject, presence: true, on: :update
  validates :owner_type, inclusion: { in: ['Newsletter', nil] }

  before_validation :set_defaults
  before_save :adjust_values

  tokenized_attributes :subject, :content, :footer, :recipient, :sender
  set_dynamic_translatable_attributes(subject: :plain, content: :html, footer: :plain)
  define_constant_methods(STATUSES, :status)

  default_scope { where(owner_type: [nil, '', 'Newsletter']) }

  scope :like, -> (*args) {
    where('subject LIKE :q OR content LIKE :q OR email_type LIKE :q OR footer LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  scope :for_newsletter, -> {
    where(email_type: [EMAIL_TYPE_NEWSLETTER_BLANK_TEMPLATE, EMAIL_TYPE_NEWSLETTER_OFFER_ANNOUCEMENT])
  }

  ##
  # List of emails that are used on class level
  def self.email_types
    [
      EMAIL_TYPE_ADVERTISER_EMAIL_VERIFICATION,
      EMAIL_TYPE_ADVERTISER_PASSWORD_RESET,
      EMAIL_TYPE_ADVERTISER_STATUS_PENDING,
      EMAIL_TYPE_ADVERTISER_STATUS_ACTIVE,
      EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED,
      EMAIL_TYPE_ADVERTISER_STATUS_SUSPENDED_DUE_TO_GDPR,
      EMAIL_TYPE_ADVERTISER_GDPR_DATA_READY,
      EMAIL_TYPE_AFFILIATE_EMAIL_VERIFICATION,
      EMAIL_TYPE_AFFILIATE_PASSWORD_RESET,
      EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_CONFIRMED,
      EMAIL_TYPE_AFFILIATE_PAYMENT_INFO_INCOMPLETE,
      EMAIL_TYPE_AFFILIATE_STATUS_ACTIVE,
      EMAIL_TYPE_AFFILIATE_STATUS_SUSPENDED,
      EMAIL_TYPE_BANNER_CREATIVE_REJECTED,
      EMAIL_TYPE_CAMPAIGN_CAP_DEPLETING,
      EMAIL_TYPE_CAMPAIGN_CAP_DEPLETED,
      EMAIL_TYPE_CAMPAIGN_APPROVED,
      EMAIL_TYPE_CAMPAIGN_INVITE_ADLINK,
      EMAIL_TYPE_CAMPAIGN_PAUSED,
      EMAIL_TYPE_CAMPAIGN_REJECTED,
      EMAIL_TYPE_EVENT_CAMPAIGN_CHANGES_REQUIRED,
      EMAIL_TYPE_EVENT_CAMPAIGN_COMPLETED,
      EMAIL_TYPE_EVENT_CAMPAIGN_REJECTED,
      EMAIL_TYPE_EVENT_CAMPAIGN_SELECTED,
      EMAIL_TYPE_FEED_CREATIVE_REJECTED,
      EMAIL_TYPE_MISSING_ORDER_REMINDER,
      EMAIL_TYPE_MISSING_ORDER_APPROVED,
      EMAIL_TYPE_MISSING_ORDER_CONFIRMING,
      EMAIL_TYPE_MISSING_ORDER_REJECTED,
      EMAIL_TYPE_NEW_MISSING_ORDERS,
      EMAIL_TYPE_OFFER_CAP_DEPLETING,
      EMAIL_TYPE_OFFER_CAP_DEPLETED,
      EMAIL_TYPE_OFFER_PAUSED_IMMEDIATE,
      EMAIL_TYPE_OFFER_PAUSED_XHOUR,
      EMAIL_TYPE_OFFER_STATUS_CHANGE,
    ]
  end

  private

  def set_defaults
    self.status ||= EmailTemplate.status_draft
    self.email_type ||= EMAIL_TYPE_NEWSLETTER_BLANK_TEMPLATE if owner_type == 'Newsletter'
    self.footer ||= st('p.newsletter_footer', company_name: DotOne::Setup.wl_name, company_email: DotOne::Setup.general_contact_email,)
  end

  def adjust_values
    subject = subject.gsub(/\r\n/, '').presence if subject.present?
  end
end
