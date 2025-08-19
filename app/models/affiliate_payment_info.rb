class AffiliatePaymentInfo < DatabaseRecords::PrimaryRecord
  include ChangesStore
  include ConstantProcessor
  include LocalTimeZone
  include Maskable
  include Traceable
  include Scopeable
  include AffiliatePaymentInfoHelpers::Downloadable
  include Forexable

  STATUSES = ['Confirmed', 'Pending', 'Waiting For Verification', 'Incomplete'].freeze
  PAYMENT_TYPES = ['Check', 'Wire Transfer', 'PayPal'].freeze

  attr_accessor :skip_validate_status

  belongs_to :affiliate, inverse_of: :payment_info, touch: true
  belongs_to :currency, foreign_key: :preferred_currency, primary_key: :code

  has_one :affiliate_address, through: :affiliate

  has_many :affiliate_assignments, through: :affiliate
  has_many :affiliate_users, through: :affiliate_assignments

  accepts_nested_attributes_for :affiliate

  validates :affiliate, presence: true
  validates :iban, length: { maximum: 23 }
  validates :preferred_currency, presence: true, on: :update
  validates :payment_type, inclusion: { in: PAYMENT_TYPES }, on: :update
  validates :paypal_email_address, format: { with: REGEX_EMAIL }, on: :update, if: :pay_pal?
  validates :bank_name, presence: true, on: :update, if: :wire_transfer?
  validates :bank_identification, :branch_identification, :branch_name,
    presence: true, on: :update, if: -> { wire_transfer? && local_tax_filing? }
  validates_with AffiliatePaymentInfoHelpers::Validator::MustHaveProperAttachment, on: :update
  validates_with AffiliatePaymentInfoHelpers::Validator::MustHaveProperStatusChange, on: :update, unless: :skip_validate_status

  before_save :adjust_values
  after_save :notify_affiliate, if: :status_previously_changed?
  after_commit :update_ongoing_payments

  delegate :full_name, :email, to: :affiliate, prefix: true, allow_nil: true
  delegate \
    :legal_resident_address, :tax_filing_country, :company_name, :ssn_ein, :phone_number, :local_tax_filing?,
    to: :affiliate, allow_nil: true
  delegate \
    :full_address, :address_1, :address_2, :city, :state, :zip_code, :country_id, :country_name,
    to: :affiliate_address, prefix: :affiliate, allow_nil: true

  define_constant_methods STATUSES, :status
  define_constant_methods PAYMENT_TYPES, :payment_type
  set_local_time_attributes :updated_at
  set_maskable_attributes :account_number
  set_forexable_attributes :latest_commission

  scope_by_affiliate

  scope :with_affiliate_name, -> (value) {
    if value.present?
      joins(:affiliate)
        .where("CONCAT_WS(' ', affiliates.first_name, affiliates.last_name) LIKE ?", "%#{value.downcase}%")
    end
  }

  scope :with_company_name, -> (value) {
    if value.present?
      joins(affiliate: :affiliate_application)
        .where('affiliate_applications.company_name LIKE ?', "%#{value.downcase}%")
    end
  }

  scope :with_affiliate_email, -> (value) {
    joins(:affiliate).where('affiliates.email LIKE ?', "%#{value.downcase}%") if value.present?
  }

  scope :with_affiliate_phone, -> (value) {
    if value.present?
      joins(affiliate: :affiliate_application)
        .where('affiliate_applications.phone_number LIKE ?', "%#{value.downcase}%")
    end
  }

  def self.final_statuses
    [
      status_confirmed,
      status_waiting_for_verification,
    ]
  end

  def self.status_considered_pending
    [
      status_incomplete,
      status_pending,
    ]
  end

  def preferred_currency_id
    currency&.id
  end

  def preferred_currency_id=(value)
    self.preferred_currency = Currency.cached_find(value)&.code
    @preferred_currency_id = value
  end

  def waiting_on_affiliate?
    pending? || incomplete?
  end

  def bank_identification=(value)
    return unless bank = Bank.find(id: value)

    self.bank_name = bank[:name]
    super(bank[:id])
  end

  def branch_key=(value)
    return unless branch = Bank.find_branch(key: value, bank_id: bank_identification)

    self.branch_identification = branch[:id]
    self.branch_name = branch[:name]
  end

  def branch_key
    Bank.to_branch_key(id: branch_identification, name: branch_name)
  end

  def notify_incomplete
    AffiliateMailer.payment_info_incomplete(affiliate).deliver_later
  end

  def notify_confirmed
    AffiliateMailer.payment_info_confirmed(affiliate).deliver_later
  end

  def notify_affiliate
    case status
    when AffiliatePaymentInfo.status_incomplete
      notify_incomplete
    when AffiliatePaymentInfo.status_confirmed
      notify_confirmed
    end
  end

  private

  # Cleanup routing number and IBAN number for Taiwan
  # since Taiwan has predefined bank and branch information
  def cleanup_inapplicable
    if local_tax_filing?
      self.routing_number = nil
      self.bank_address = nil
      self.iban = nil
    else
      self.bank_identification = nil
      self.branch_identification = nil
    end
  end

  def adjust_values
    self.status ||= AffiliatePaymentInfo.status_pending
    self.payment_type ||= AffiliatePaymentInfo.payment_type_wire_transfer

    cleanup_inapplicable

    if preferred_currency_changed?
      self.forex_latest_commission = [latest_commission.to_f, preferred_currency_was || Currency.platform.code]
    end

    if status_changed? && confirmed?
      self.confirmed_at = Time.now
    end
  end

  def update_ongoing_payments
    return unless patched_previous_changes[:status].present? || patched_previous_changes[:preferred_currency].present?

    AffiliatePaymentInfos::PropagateToPaymentJob.perform_later(id)
  end
end
