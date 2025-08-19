class AffiliatePayment < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include LocalDateZone
  include StaticTranslatable
  include BillingRegioned
  include AffiliatePaymentHelpers::Downloadable
  include Relations::AffiliateAssociated
  include Relations::CountryAssociated

  STATUSES = [
    'Pending',
    'Redeemable',
    'Redeemed',
    'Confirmed',
    'Paid',
    'Deferred',
    'Suspended',
  ].freeze

  # Available Currencies for
  # affiliate payments
  AVAILABLE_CURRENCIES = [
    :TWD,
    :USD,
    :HKD,
    :SGD,
    :AUD,
    :MYR,
    :JPY,
  ].freeze

  # Redeem payment has minimum balance
  # based on the preferred currency
  MINIMUM_REDEEM_AMOUNT = {
    aud: 130,
    hkd: 780,
    myr: 200,
    sgd: 130,
    twd: 1000,
    usd: 100,
    jpy: 12_000,
  }.freeze

  # Wire Fee is based on Preferred Currency
  WIRE_FEE = {
    aud: 22,
    hkd: 118,
    myr: 70,
    sgd: 21,
    twd: 30,
    usd: 15,
    jpy: 1570,
  }.freeze

  # Any redeem balance more than
  # this threshold will be exempt.
  # At the moment, this is only for
  # Taiwan Filing Country only (TWD)
  TAX_EXEMPT_REDEEMED_THRESHOLD = 20_000

  # At the moment, Tax Rate is for Taiwan Filing Country
  TAX_RATE = 0.10

  TAX_COUNTRIES = ['China', 'Taiwan', 'Hong Kong', 'Thailand', 'Indonesia', 'Malaysia', 'Vietnam', 'Singapore', 'United States'].freeze

  has_many :payment_fees, inverse_of: :affiliate_payment, dependent: :destroy
  has_many :affiliate_users, through: :affiliate

  has_one :wire_fee, -> { wire_fees }, class_name: 'PaymentFee', autosave: true
  has_one :tax_fee, -> { tax }, class_name: 'PaymentFee', autosave: true
  has_one :payment_info, through: :affiliate

  accepts_nested_attributes_for :payment_fees

  mount_uploader :conversion_file, FileUploader

  validates :affiliate_id, :paid_date, :start_date, :end_date, presence: true
  validates_with AffiliatePaymentHelpers::Validator::AffiliatePaymentValidator

  before_create :copy_affiliate_payment_info
  before_save :calculate
  before_save :adjust_values
  after_save_commit :update_payment_info_latest_commissions
  after_commit :queue_update_affiliate_balance
  after_commit :queue_download_conversions, on: :create

  define_constant_methods AffiliatePaymentInfo::PAYMENT_TYPES, :payment_type
  define_constant_methods STATUSES, :status
  define_constant_methods AffiliatePaymentInfo::STATUSES, :payment_info_status, prefix_instance: :payment_info, skip_scope: true
  set_static_translatable_attributes :tax_filing_country, tax_filing_country: 'country.name'
  set_local_date_attributes :start_date, :end_date, :paid_date, time_zone: TimeZone.platform

  # To find out any payments that are still not final (ongoing).
  # Ongoing payments are subject to payment info changes
  scope :ongoing, -> { where(status: status_considered_ongoing) }

  scope :previous_records, -> (current) {
    where('start_date <= ?', current.start_date || TimeZone.platform.from_utc(Time.now).to_date)
      .where(affiliate_id: current.affiliate_id)
      .where.not(id: current.id)
      .order(end_date: :desc, id: :desc)
  }

  scope :next_records, -> (current) {
    where('start_date >= ?', current.end_date || TimeZone.platform.from_utc(Time.now).to_date)
      .where(affiliate_id: current.affiliate_id)
      .where.not(id: current.id)
      .order(start_date: :asc, id: :asc)
  }

  scope :overlapped_payments, -> (affiliates, billing_region, start_date, end_date) {
    with_billing_regions(billing_region)
      .with_affiliates(affiliates)
      .where(
        '(start_date BETWEEN :start AND :end OR end_date BETWEEN :start AND :end) OR (start_date <= :start AND end_date >= :end)',
        start: start_date, end: end_date,
      )
  }

  scope :latest_period, -> { order(start_date: :desc, id: :desc) }

  delegate :company?, :company_name, :ssn_ein, :legal_resident_address, to: :affiliate, allow_nil: true

  def self.statuses(access_level = :all)
    case access_level
    when :limited
       [
        status_pending,
        status_deferred,
        status_suspended,
      ]
    when :no_redeemed
      [
        status_pending,
        status_redeemable,
        status_confirmed,
        status_paid,
        status_deferred,
        status_suspended,
      ]
    when :balance
      [
        status_confirmed,
        status_paid,
        status_deferred,
        status_suspended
      ]
    else
      STATUSES
    end
  end

  def self.status_considered_ongoing
    [
      status_pending,
      status_redeemable,
    ]
  end

  def self.calculate_earnings(value)
    value.to_f * REFERRAL_BONUS_MULTIPLIER
  end

  ##
  # For payment with invoice, it is tax exempt
  def tax_exempt?
    # Non Taiwan tax filling country will get tax exempt
    return true unless tax_filing_country == 'Taiwan'
    return true if company?

    has_invoice || redeemed_amount.to_f <= TAX_EXEMPT_REDEEMED_THRESHOLD
  end

  def redeemable?
    return false if preferred_currency.blank?

    currency_code = preferred_currency.downcase.to_sym

    currency_code.present? &&
      status == AffiliatePayment.status_redeemable &&
      total_commissions >= MINIMUM_REDEEM_AMOUNT[currency_code]
  end

  def previous_records
    AffiliatePayment.previous_records(self)
  end

  def next_records
    AffiliatePayment.next_records(self)
  end

  def previous_one
    @previous_one ||= previous_records.first
  end

  def next_one
    @next_one ||= next_records.first
  end

  def total_commissions
    previous_amount.to_f + affiliate_amount.to_f + referral_amount.to_f
  end

  def tax_fee_amount
    tax_fee&.amount.to_f
  end

  def tax_fee_amount=(value)
    if tax_fee.present?
      self.tax_fee.amount = value.to_f
    else
      build_tax_fee(amount: value.to_f)
    end
  end

  def wire_fee_amount
    wire_fee&.amount.to_f
  end

  def wire_fee_amount=(value)
    if wire_fee.present?
      self.wire_fee.amount = value.to_f
    else
      build_wire_fee(amount: value.to_f)
    end
  end

  def total_fees
    payment_fees.sum(:amount)
  end

  def mailing_country
    country&.name
  end

  def non_redeemed_amount
    (total_commissions - redeemed_amount.to_f).round(2)
  end

  # Payment after tax withold
  # but before wire fee
  def post_tax_payment_amount
    (redeemed_amount.to_f - tax_fee_amount).round(2)
  end

  # Payment after tax withold and
  # wire fee
  def net_payment_amount
    (post_tax_payment_amount - wire_fee_amount).round(2)
  end

  def taxable_payment
    (redeemed_amount.to_f - wire_fee_amount).round(2)
  end

  def redeem
    if payment_info_confirmed? && redeemable? && redeemed_amount.to_f > 0
      self.status = AffiliatePayment.status_redeemed

      unless tax_exempt?
        tax_fee ||= build_tax_fee
        tax_fee.amount = redeemed_amount.to_f * TAX_RATE
      end

      save
    else
      false
    end
  end

  def query_conversions
    AffiliateStat
      .approved_conversions_for_affiliates(affiliate_id, start_date, end_date)
      .order(converted_at: :desc)
      # .with_billing_regions(billing_region)
  end

  def download_conversions!
    return if query_conversions.empty?

    download = Download.new(
      headers: AffiliateStat.generate_download_headers(user: affiliate, include_conversion_data: true),
      file_type: 'AffiliateStat',
      currency_code: preferred_currency,
      time_zone: TimeZone.platform,
      locale: affiliate.locale,
    )

    download.generate_tmp_file('csv') do |file|
      csv = CSV.new(file)
      csv << download.report_headers
      query_conversions.find_each(batch_size: 250) do |conversion|
        csv << download.build_row(conversion)
      end

      self.conversion_file = file
      self.save!
    end
  end

  def queue_download_conversions
    AffiliatePayments::DownloadConversionsJob.perform_later(id)
  end

  def propagate_payment_info!
    return unless AffiliatePayment.status_considered_ongoing.include?(status)

    copy_affiliate_payment_info
    if preferred_currency != payment_info.preferred_currency
      rate = Currency.rate(preferred_currency, payment_info.preferred_currency)
      payment_fees.each do |fee|
        fee.update(amount: rate * fee.amount.to_f)
      end

      self.previous_amount = rate * previous_amount.to_f
      self.redeemed_amount = rate * redeemed_amount.to_f
      self.affiliate_amount = rate * affiliate_amount.to_f
      self.referral_amount = rate * referral_amount.to_f
    end

    save!
  end

  private

  def determine_tax_region
    source_country = country&.name || tax_filing_country

    if TAX_COUNTRIES.include?(source_country)
      source_country
    elsif source_country.present?
      'Others'
    else
      'Unknown'
    end
  end

  def copy_affiliate_payment_info
    return unless affiliate.present?

    self.business_entity = affiliate.business_entity
    self.tax_filing_country = affiliate.tax_filing_country
    self.legal_resident_address = affiliate.legal_resident_address

    if payment_info
      # Copy payment info
      self.payment_type = payment_info.payment_type
      self.payee_name = payment_info.payee_name
      self.bank_identification = payment_info.bank_identification
      self.bank_name = payment_info.bank_name
      self.branch_identification = payment_info.branch_identification
      self.branch_name = payment_info.branch_name
      self.iban = payment_info.iban
      self.account_number = payment_info.account_number
      self.paypal_email_address = payment_info.paypal_email_address
      self.preferred_currency = payment_info.preferred_currency || Currency.platform_code
      self.payment_info_status = payment_info.status
      self.routing_number = payment_info.routing_number

      # Copy affiliate_address
      self.address1 = payment_info.affiliate_address_1
      self.address2 = payment_info.affiliate_address_2
      self.zip_code = payment_info.affiliate_zip_code
      self.country_id = payment_info.affiliate_country_id
      self.city = payment_info.affiliate_city
      self.state = payment_info.affiliate_state
    end

    self.tax_region = determine_tax_region
  end

  def calculate
    if redeemed_amount.to_f > 0
      # Assign any wire fee
      if currency_code = preferred_currency&.downcase&.to_sym
        self.wire_fee ||= build_wire_fee
        self.wire_fee.amount = WIRE_FEE[currency_code] if wire_fee.amount.to_f == 0
      end

      # Assign or update any tax fee
      unless tax_exempt?
        self.tax_fee ||= build_tax_fee
        self.tax_fee.amount = TAX_RATE * redeemed_amount.to_f if tax_fee.amount.to_f == 0
      end
    end

    if paid?
      self.amount = redeemed_amount.to_f - tax_fee&.amount.to_f - wire_fee&.amount.to_f
    end

    if AffiliatePayment.statuses(:balance).include?(status)
      self.balance = total_commissions - total_fees - amount.to_f
    end
  end

  def adjust_values
    self.period_start_at = TimeZone.platform.to_utc(start_date) if start_date.present?
    self.period_end_at = TimeZone.platform.to_utc(end_date) if end_date.present?
    self.paid_at = TimeZone.platform.to_utc(paid_date) if paid_date.present?
  end

  def update_payment_info_latest_commissions
    return unless payment_info

    latest_payment = AffiliatePayment
      .where.not(status: AffiliatePayment.status_pending)
      .where(affiliate_id: affiliate_id)
      .latest_period
      .first

    payment_info.latest_commission = latest_payment&.total_commissions.to_f
    payment_info.save(validate: false)
  end

  def queue_update_affiliate_balance
    Affiliates::UpdateBalanceJob.perform_later(affiliate_id)
  end
end
