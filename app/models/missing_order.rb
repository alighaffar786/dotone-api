class MissingOrder < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Downloadable
  include Forexable
  include LocalTimeZone
  include PurgeableFile
  include StaticTranslatable
  include Traceable
  include MissingOrderHelpers::Downloadable
  include Relations::AffiliateAssociated
  include Relations::CurrencyAssociated
  include Relations::OfferAssociated
  include Tokens::Tokenable

  STATUSES = ['Pending', 'Approved', 'Rejected' ,'Rejected by Admin', 'Rejected by Advertiser', 'Confirming', 'Completed']
  QUESTION_TYPES = ['No Postback', 'Incorrect Amount', 'Unconfirmed', 'Other']
  PAYMENT_METHODS = ['Cash', 'Card', 'Atm', 'Line', 'Jkos', 'Others', 'PayPal', 'Apple', 'WeChat']
  DEVICES = ['Desktop', 'Mobile', 'Tablet', 'Unknown']

  # Approval Related
  APPROVAL_SUMMARIES = ['Amount Adjusted', 'Order Confirmed', 'Order Added', 'Others']

  # Rejection Related
  REJECTION_SUMMARIES = ['Source Invalid', 'Order Expired', 'Coupon Invalid', 'Without Commission',
    'Without Some Commission', 'Not Due', 'Others']

  STATUS_SUMMARIES = APPROVAL_SUMMARIES | REJECTION_SUMMARIES

  attr_accessor :skip_notification, :should_notify_users, :do_update_amounts

  belongs_to :order, inverse_of: :missing_order, touch: true

  has_one :screenshot, as: :owner, class_name: 'Image', inverse_of: :owner, dependent: :destroy
  has_one :network, through: :offer

  has_many :affiliate_users, through: :network

  accepts_nested_attributes_for :order, reject_if: :ignore_order?

  validates :affiliate_id, presence: true
  validates :offer_id, :order_number, presence: true, if: -> { new_record? && question_type_no_postback? }
  validates :order_id, presence: true, if: -> { new_record? && (question_type_incorrect_amount? || question_type_unconfirmed?) }
  validates :currency_id, :order_time, :order_total, presence: true, if: :question_type_no_postback?
  validates :status, inclusion: { in: STATUSES }
  validates :question_type, inclusion: { in: QUESTION_TYPES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS, allow_blank: true }
  validates :device, inclusion: { in: DEVICES, allow_blank: true }
  validates :status_summary, inclusion: { in: STATUS_SUMMARIES, allow_blank: true }
  validates_with MissingOrderHelpers::Validator::ClickTimeTooOld

  before_validation :set_defaults
  after_validation :populate_order
  after_save :do_notify_users
  after_commit :notify_affiliate, on: :update, if: :should_notify_users
  after_commit :notify_network, on: :update, if: :should_notify_users

  define_constant_methods(STATUSES, :status)
  define_constant_methods(QUESTION_TYPES, :question_type, prefix_instance: :question_type)
  define_constant_methods(PAYMENT_METHODS, :payment_method, prefix_instance: :payment_method)
  define_constant_methods(DEVICES, :device, prefix_instance: :device)
  define_constant_methods(STATUS_SUMMARIES, :status_summary)

  set_forexable_attributes :order_total, :true_pay
  set_local_time_attributes :created_at, :order_time, :click_time, :confirming_at
  set_purgeable_file_attributes :screenshot_cdn_url
  set_static_translatable_attributes :status_summary, :payment_method, :device
  set_token_prefix :missing_order

  scope :with_networks, -> (*args) {
    if args.present?
      values = args.flatten.map { |x| x.try(:id) || x }
      includes(:offer).where(offers: { network_id: values })
    end
  }

  scope :confirming_n_days_ago, -> (n_days) {
    where(confirming_at: n_days.days.ago.beginning_of_day..n_days.days.ago.end_of_day)
  }

  scope :confirming_n_days_ago_or_older, -> (n_days) {
    where('missing_orders.confirming_at < ?', n_days.days.ago.end_of_day)
  }

  scope :sort_by_status, -> {
    order(Arel.sql("FIELD(missing_orders.status, '#{statuses_sorted.join('\',\'')}')"))
  }

  def self.statuses(role = nil)
    if role == :network
      [
        status_confirming,
        status_approved,
        status_rejected,
        status_rejected_by_admin,
        status_rejected_by_advertiser,
        status_completed,
      ]
    else
      STATUSES
    end
  end

  def self.statuses_sorted
    [
      status_pending,
      status_confirming,
      status_approved,
      status_rejected,
      status_rejected_by_admin,
      status_rejected_by_advertiser,
      status_completed,
    ]
  end

  def self.status_considered_rejected
    [
      status_rejected,
      status_rejected_by_admin,
      status_rejected_by_advertiser,
    ]
  end

  def self.status_considered_final
    [
      status_rejected,
      status_rejected_by_admin,
      status_rejected_by_advertiser,
      status_approved,
      status_completed,
    ]
  end

  def self.approval_summaries
    APPROVAL_SUMMARIES
  end

  def self.rejection_summaries
    REJECTION_SUMMARIES
  end

  def self.rejecters
    {
      system: status_rejected,
      admin: status_rejected_by_admin,
      advertiser: status_rejected_by_advertiser,
    }
  end

  def considered_rejected?
    MissingOrder.status_considered_rejected.include?(status)
  end

  def considered_final?
    MissingOrder.status_considered_final.include?(status)
  end

  def considered_completed?
    transaction_status != AffiliateStat.approval_pending && considered_final?
  end

  def order_added?
    approved? && status_summary == MissingOrder.status_summary_order_added
  end

  def ignore_order?
    !order_added?
  end

  def affiliate_stat
    order&.affiliate_stat
  end

  def offer_variant
    offer&.default_offer_variant
  end

  def conversion_step
    offer&.default_conversion_step
  end

  def days_until_auto_approval
    return if confirming_at.blank?

    (confirming_at.to_date - 30.days.ago.to_date).to_i
  end

  def offer_id_with_name
    offer&.id_with_name
  end

  def order_applicable?
    order_id.present? || (offer_id.present? && order_number.present?)
  end

  def found_order_id
    order_id || find_order&.id
  end

  # Will no longer needed in the future
  def find_order
    Order.find_by(offer_id: offer_id, order_number: order_number, affiliate_id: affiliate_id)
  end

  def auto_approve!
    return unless confirming?

    self.skip_notification = true
    self.status = MissingOrder.status_approved
    self.status_summary = MissingOrder.status_summary_order_added
    save!

    result = process_stat_conversion

    if result.present? && result[:errors].present?
      update(
        status: MissingOrder.status_rejected,
        status_summary: MissingOrder.status_summary_others,
        status_reason: result[:errors]
      )
    else
      self.skip_notification = false
      notify_affiliate
    end
  end

  def process_stat_conversion
    return if order.blank?
    return if Order.statuses_considered_approved.include?(order.status)

    if Order.statuses_considered_rejected.include?(order.status)
      result[:errors] = order.status
    else
      options = {
        approval: AffiliateStat.approval_pending,
        order_total: order.total,
        order_number: order.order_number,
        step_name: order.step_name,
        skip_currency_adjustment: true,
        trace_agent_via: trace_agent_via,
      }

      options[:revenue] = order.platform_true_pay if order.platform_true_pay > 0
      result = affiliate_stat.process_conversion!(options)

      update(order_id: result[:order].id) if result[:order].present?
      result
    end
  end

  def screenshot_cdn_url
    super.presence || screenshot&.cdn_url
  end

  def transaction_status
    @transaction_status ||= order&.copy_stat&.approval.presence
  end

  def rejecter
    MissingOrder.rejecters.invert[status]
  end

  def do_notify_users
    self.should_notify_users = status_previously_changed?
  end

  def notify_affiliate
    transaction do
      MissingOrders::NotifyAffiliateJob.perform_later(id) unless skip_notification
    end
  end

  def notify_network
    transaction do
      MissingOrders::NotifyNetworkJob.perform_later(id) unless skip_notification
    end
  end

  def self.bulk_touch(ids)
    where(id: ids).update_all(updated_at: Time.now)
  end

  def self.bulk_touch_by_offer_ids(offer_ids)
    where(offer_id: offer_ids).update_all(updated_at: Time.now)
  end

  private

  def set_defaults
    self.status ||= MissingOrder.status_pending
    self.confirming_at ||= Time.now if status_changed? && confirming?
    self.currency_id ||= Currency.platform.id

    # Means Order/Transaction total is incorrect and user provided us only order_id
    if order_id.present?
      self.offer_id ||= order.offer_id
      self.order_time ||= order.recorded_at
      self.order_number ||= order.order_number
    end

    # Means Order/Transaction was not captured and user provided us offer_id and order_number
    self.order_id ||= find_order&.id

    # Click time is optional, so try and find it
    self.click_time ||= order&.affiliate_stat&.recorded_at
  end

  def populate_order
    return unless order_applicable? && status_summary_changed? && order_added?

    if order.present?
      return unless do_update_amounts

      self.order.assign_attributes(
        total: forex_order_total(order.original_currency),
        true_pay: forex_true_pay(order.original_currency),
      )
    else
      return unless affiliate_stat = create_click_stat

      self.build_order(
        affiliate_stat_id: affiliate_stat.id,
        status: Order.status_pending,
        offer_id: offer_id,
        affiliate_id: affiliate_id,
        offer_variant_id: offer_variant.id,
        step_name: conversion_step.name,
        step_label: conversion_step.label,
        affiliate_conv_type: conversion_step.affiliate_conv_type,
        true_conv_type: conversion_step.true_conv_type,
        order_number: order_number,
        total: platform_order_total,
        true_pay: platform_true_pay,
        original_currency: Currency.platform_code,
        recorded_at: order_time || Time.now,
        trace_agent_via: trace_agent_via,
      )
    end
  end

  def create_click_stat
    return if affiliate_stat.present? || offer_id.blank? || affiliate_id.blank?

    AffiliateStat.create(
      clicks: 1,
      language_id: network.language_id,
      network_id: offer.network_id,
      offer_id: offer_id,
      offer_variant_id: offer_variant.id,
      affiliate_id: affiliate_id,
      recorded_at: click_time || order_time || Time.now,
      affiliate_offer_id: AffiliateOffer.best_match(affiliate, offer)&.id,
      manual_notes: "Created for #{trace_agent_via}",
    )
  end

  def trace_agent_via
    "Missing Order (#{id})"
  end
end
