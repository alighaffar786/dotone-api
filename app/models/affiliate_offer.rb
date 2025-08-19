class AffiliateOffer < DatabaseRecords::PrimaryRecord
  include AffHashable
  include AffiliateLoggable
  include ConstantProcessor
  include DateRangeable
  include Forexable
  include HasCap
  include LocalTimeZone
  include ModelCacheable
  include Scopeable
  include Traceable
  include AffiliateOfferHelpers::Downloadable
  include Relations::AffiliateAssociated
  include Relations::AffiliateStatAssociated
  include Relations::OfferAssociated
  include Tokens::Tokenable

  APPROVAL_STATUSES = [
    'Apply',
    'Active',
    'Pending',
    'Confirming',
    'Paused',
    'Suspended',
    'Cancelled',
    'Waiting on Affiliate',
    'Selected',
    'Under Evaluation',
    'Changes Required',
    'Completed',
    'Unqualified',
  ]

  STATUS_SUMMARY_NOT_SELECTED = 'Not Selected'
  STATUS_SUMMARY_NOT_APPROVED = 'Not Approved'
  STATUS_SUMMARY_TERMS_VIOLATION = 'Terms Violation'

  STATUS_SUMMARIES = [
    STATUS_SUMMARY_NOT_SELECTED,
    STATUS_SUMMARY_NOT_APPROVED,
    STATUS_SUMMARY_TERMS_VIOLATION,
  ]

  CAP_REDIRECTS = ['Soft', 'Hard']

  attr_accessor :bulk_conversion_step_id, :bulk_step_price_attributes, :event_contract_signed,
    :is_subject_to_site_info_check

  belongs_to :event_offer, inverse_of: :affiliate_offers, foreign_key: :offer_id
  belongs_to :site_info, inverse_of: :affiliate_offers, touch: true
  belongs_to :cap_time_zone_item, inverse_of: :affiliate_offers, foreign_key: :cap_time_zone, class_name: 'TimeZone'

  has_many_affiliate_stats
  has_many :step_prices, inverse_of: :affiliate_offer, dependent: :destroy
  has_many :conversion_steps, through: :step_prices
  has_many :pay_schedules, through: :step_prices
  has_many :step_pixels, inverse_of: :affiliate_offer, dependent: :destroy

  has_one :default_offer_variant, through: :offer
  has_one :default_conversion_step, through: :offer
  has_one :offer_cap, through: :default_offer_variant
  alias offer_variant default_offer_variant

  accepts_nested_attributes_for :step_prices
  accepts_nested_attributes_for :step_pixels, reject_if: -> (attrs) {
    attrs['conversion_pixel_html'].blank? && attrs['conversion_pixel_s2s'].blank?
  }

  validates :offer_id, presence: true, uniqueness: { scope: :affiliate_id }
  validates :affiliate_id, presence: true, on: :update
  validates :approval_status, inclusion: { in: APPROVAL_STATUSES }
  # TODO: Change default cap_redirect to 'Soft' and update existing data
  # validates :cap_redirect, inclusion: { in: CAP_REDIRECTS, allow_blank: true }
  # TODO: Remove cap_type default and update existing data
  # validates :cap_type, inclusion: { in: CAP_TYPES, allow_blank: true }
  validates_with AffiliateOfferHelpers::Validator::SiteInfoRequired, if: :is_subject_to_site_info_check

  # order of these callbacks matter!
  before_validation :set_defaults, on: :create
  before_save :adjust_values
  before_save :reset_step_prices, if: :is_custom_commission_changed?
  before_save :bulk_set_step_prices_attributes, if: :bulk_conversion_step_id
  before_save :log_changes_for_network
  after_save :send_email_for_approval_permission
  after_save :schedule_reset_cap
  after_commit :notify, on: :update

  define_constant_methods APPROVAL_STATUSES, :approval_status
  define_constant_methods STATUS_SUMMARIES, :status_summary
  define_constant_methods CAP_REDIRECTS, :cap_redirect
  set_token_prefix :campaign
  set_local_time_attributes :created_at, :event_contract_signed_at, :approval_status_changed_at

  set_predefined_flag_attributes :claim_message, :shipping_address
  set_predefined_flag_attributes :cap_depleted, type: :boolean
  set_predefined_flag_attributes :requested_affiliate_pay, type: :float
  set_predefined_flag_attributes :conversion_so_far, type: :integer
  set_predefined_flag_attributes :token_refreshed_at, type: :string
  set_instance_cache_methods :aff_hash

  set_forexable_attributes :requested_affiliate_pay, :effective_affiliate_pay

  trace_has_many_includes :conversion_steps, :step_prices, :pay_schedules

  scope_by_network 'offers.network_id'

  scope :suspended, -> {
    joins(offer: :default_offer_variant)
      .where(approval_status: approval_status_suspended)
      .merge(OfferVariant.not_suspended)
  }

  scope :not_approved, -> {
    where(approval_status: approval_status_suspended, status_summary: STATUS_SUMMARY_NOT_APPROVED)
  }

  scope :non_suspended, -> { where.not(approval_status: approval_status_suspended) }

  scope :non_rejected_for_event, -> {
    joins(:event_offer).where.not(approval_status: approval_status_considered_rejected)
  }

  scope :reappliable, -> { cancelled.or(not_approved) }

  scope :not_cancelled, -> { where.not(approval_status: approval_status_cancelled) }

  scope :campaign_data_count, -> {
    time_zone = TimeZone.current
    select(
      <<-SQL.squish
        offer_id, affiliate_id,
        CONVERT_TZ(created_at, '+00:00', '#{time_zone.gmt_string}') as created_at,
        COUNT(id) AS total_application,
        COALESCE(sum(CASE WHEN approval_status = 'Active' THEN 1 ELSE 0 END), 0) AS active_count,
        COALESCE(sum(CASE WHEN approval_status = 'Suspended' THEN 1 ELSE 0 END), 0) AS suspended_count,
        COALESCE(sum(CASE WHEN approval_status = 'Paused' THEN 1 ELSE 0 END), 0) AS paused_count
      SQL
    )
  }

  scope :daily, -> {
    # time_zone = TimeZone.default
    time_zone = TimeZone.current
    group("DATE(CONVERT_TZ(created_at, '+00:00', '#{time_zone.gmt_string}'))")
  }

  scope :recently_applied, -> { order(created_at: :desc, id: :desc) }

  scope :order_by_approval_status, -> {
    order(Arel.sql("FIELD(affiliate_offers.approval_status, '#{approval_statuses_sorted.join('\',\'')}')"))
  }

  def self.approval_statuses(include_cancelled = true)
    [
      approval_status_active,
      approval_status_pending,
      approval_status_confirming,
      approval_status_paused,
      approval_status_suspended,
      include_cancelled ? approval_status_cancelled : nil
    ].compact
  end

  def self.approval_statuses_sorted
    [
      approval_status_pending,
      approval_status_confirming,
      approval_status_active,
      approval_status_selected,
      approval_status_paused,
      approval_status_waiting_on_affiliate,
      approval_status_under_evaluation,
      approval_status_changes_required,
      approval_status_completed,
      approval_status_unqualified,
      approval_status_suspended,
      approval_status_cancelled,
    ]
  end

  def self.event_approval_statuses
    [
      approval_status_pending,
      approval_status_confirming,
      approval_status_selected,
      approval_status_under_evaluation,
      approval_status_changes_required,
      approval_status_completed,
      approval_status_unqualified,
      approval_status_suspended,
    ]
  end

  def self.approval_status_considered_approved
    [
      approval_status_active,
      approval_status_selected,
      approval_status_completed,
    ]
  end

  def self.approval_statuses_considered_pending
    [
      approval_status_pending,
      approval_status_confirming,
    ]
  end

  def self.approval_status_considered_rejected
    [
      approval_status_unqualified,
      approval_status_suspended,
      approval_status_cancelled,
    ]
  end

  def self.event_status_considered_selected
    [
      approval_status_selected,
      approval_status_under_evaluation,
      approval_status_changes_required,
    ]
  end

  def self.event_approval_considered_applied
    event_approval_statuses - approval_status_considered_rejected
  end

  def self.best_match(affiliate, offer)
    return if affiliate.blank? || offer.blank?

    ckey = DotOne::Utils.to_global_cache_key([self, affiliate, offer], :best_match)

    DotOne::Cache.fetch(ckey) do
      AffiliateOffer.find_by(affiliate_id: affiliate.id, offer_id: offer.id)
    end
  end

  def self.active_best_match(affiliate, offer)
    return unless affiliate&.active?
    return unless offer&.active?

    affiliate_offer = AffiliateOffer.best_match(affiliate, offer)
    affiliate_offer if affiliate_offer&.considered_approved?
  end

  ##
  # ONLY USE this method when we are sure that
  # affiliate is safe to be assigned to an offer variant
  # without our team's involvement in approving/rejecting
  # the campaign
  def self.best_match_or_create(affiliate, offer, is_auto_applied = false, check_need_approval = false)
    return if affiliate.blank? || offer.blank?

    affiliate_offer = AffiliateOffer.best_match(affiliate, offer)
    considered_blank = affiliate_offer.blank? || affiliate_offer.cancelled?

    return if considered_blank && (!affiliate.active? || !offer.active_public?)
    return if considered_blank && check_need_approval && offer.need_approval?

    if considered_blank
      affiliate_offer&.destroy
      affiliate_offer = nil
    end

    affiliate_offer ||= AffiliateOffer.create(
      affiliate_id: affiliate.id,
      agree_to_terms: true,
      offer_id: offer.id,
      is_auto_applied: is_auto_applied,
    )

    affiliate_offer if affiliate_offer.persisted?
  end

  def reappliable?
    cancelled? || suspended? && not_approved?
  end

  def refresh_track_token!
    self.token_refreshed_at = Time.now.to_i
    save!
  end

  def cached_offer_variant
    cached_offer.cached_default_offer_variant
  end

  def offer_variant_id
    cached_offer_variant.id
  end

  def considered_approved?
    AffiliateOffer.approval_status_considered_approved.include?(approval_status)
  end

  def considered_selected?
    AffiliateOffer.event_status_considered_selected.include?(approval_status)
  end

  def approval_status_for_affiliate
    if offer.is_a?(NetworkOffer)
      network_offer_approval_status
    elsif offer.is_a?(EventOffer)
      event_offer_approval_status
    end
  end

  def network_offer_approval_status
    return unless offer.is_a?(NetworkOffer)

    if suspended?
      approval_status
    elsif offer_variant.considered_positive? && !cancelled?
      if offer_variant.fulfilled? && !active?
        offer_variant.status
      else
        approval_status
      end
    else
      offer_variant.status
    end
  end

  def event_offer_approval_status
    return unless offer.is_a?(EventOffer)

    if offer_variant.active?
      approval_status
    elsif offer_variant.fulfilled? && !cancelled?
      approval_status
    else
      offer_variant.status
    end
  end

  def notify_application_approval
    notifier = if active?
      :campaign_approved
    elsif selected?
      :event_campaign_selected
    elsif changes_required?
      :event_campaign_changes_required
    elsif completed?
      :event_campaign_completed
    elsif suspended?
      unless not_selected?
        offer.is_a?(EventOffer) ? :event_campaign_rejected : :campaign_rejected
      end
    elsif paused?
      :campaign_paused
    end

    return unless notifier
    return unless affiliate.notify_application_approval?

    AffiliateMailer.send(notifier, self, cc: true).deliver_later
  end

  def default_step_price
    @default_step_price ||= step_prices.find do |step_price|
      step_price.conversion_step_id == default_conversion_step.id
    end
  end

  # returns true when this affiliate offer will use base commission
  def base_commission?
    is_custom_commission != true
  end

  def reset_cap!
    return if cap_type.blank?

    if cap_size.blank?
      flag(:cap_depleted, false)
    elsif (cap_size.to_i - conversion_so_far.to_i) > 0
      flag(:cap_depleted, false)
    elsif (cap_size.to_i - conversion_so_far.to_i) <= 0
      flag(:cap_depleted, true)
    end
  end

  ##
  # Eligible recipients for cap notification
  def cap_notification_recipients
    @cap_notification_recipients ||= begin
      recipients = [affiliate, affiliate.contact_lists, affiliate.affiliate_users]
      recipients.flatten.uniq(&:email)
    end
  end

  def notify_on_cap_depleted!(cap_instance, lower_threshold, upper_threshold)
    return unless cap_notification_email?

    cap_notifier = DotOne::Services::CapNotifier.new(instance_to_notify: self, notification_type: :campaign)

    cap_checker = DotOne::Services::CapChecker.new(
      lower_threshold: lower_threshold,
      upper_threshold: upper_threshold,
      cap_instance: cap_instance,
      cap_size: cap_size,
      cap_notified_at: cap_notified_at,
    )

    cap_checker.check do |checker|
      checker.when_depleting do |_cap_instance|
        cap_notifier.send_depleting_email(cap_notification_recipients)
      end

      checker.when_depleted do |cap_instance|
        cap_notifier.send_depleted_email(cap_notification_recipients)
        cap_instance.flag(:cap_depleted, true)
      end

      checker.when_reset do |cap_instance|
        cap_instance.update(cap_notified_at: nil)
      end
    end
  end

  def to_token_params
    token_params = { affiliate_offer_id: id, affiliate_id: affiliate_id }
    token_params[:tr] = token_refreshed_at if token_refreshed_at.present?
    token_params
  end

  def to_tracking_url(params = {})
    cached_offer_variant.to_tracking_url(
      token_params: to_token_params,
      extra_params: params,
    )
  end

  def deeplink_preview_url
    @deeplink_preview_url = offer.destination_url.presence
    @deeplink_preview_url ||= ClickStat.interpolate(default_offer_variant.destination_url)
    @deeplink_preview_url
  end

  ##
  # Method to calculate percentage of cap remaining
  def cap_percentage_remaining
    return if cap_size.to_i == 0

    remaining = 100 - ((conversion_so_far.to_f / cap_size.to_f) * 100)
    remaining.to_i
  end

  def cap_percentage_used
    return if cap_size.to_i == 0

    cap_used = (conversion_so_far.to_f / cap_size.to_f) * 100
    "#{cap_used.to_i}%"
  end

  # TODO: For some reason cap_type default value on db
  # is set to 'soft' which does not make any sense.
  # Remove and fix it then adjust this method for better
  # definition of has_cap?
  def has_cap?
    cap_type.present? &&
      cap_type != 'soft' &&
      cap_size.present?
  end

  ##
  # Method to grab all information of
  # related conversion points.
  # The returned hash contains all conversion points
  # with price/share points that are related to
  # this campaign's affiliate thru its step prices.
  def related_conversion_point_information
    transform = proc do |value, original = nil|
      new_value = value.to_f

      if new_value == 0
        original.to_f == 0 ? nil : original.to_f
      else
        new_value
      end
    end

    to_return = {}

    # 1. Obtain from current affiliate offer
    cached_offer.cached_ordered_conversion_steps.each do |step|
      step_name = step.name

      to_return[step_name] = {
        true_share: transform.call(step.true_share),
        true_pay: transform.call(step.true_pay),
        affiliate_share: transform.call(step.affiliate_share),
        affiliate_pay: transform.call(step.affiliate_pay),
        currency_code: step.original_currency,
        true_conv_type: step.true_conv_type,
        affiliate_conv_type: step.affiliate_conv_type,
      }

      next unless schedule = step.active_pay_schedule

      to_return[step_name] = {
        true_share: transform.call(schedule.true_share, step.true_share),
        true_pay: transform.call(schedule.true_pay, step.true_pay),
        affiliate_share: transform.call(schedule.affiliate_share, step.affiliate_share),
        affiliate_pay: transform.call(schedule.affiliate_pay, step.affiliate_pay),
        starts_at: schedule.starts_at,
        ends_at: schedule.ends_at,
        currency_code: schedule.original_currency,
        true_conv_type: step.true_conv_type,
        affiliate_conv_type: step.affiliate_conv_type,
      }
    end

    # 2. Obtain from any existing step prices
    step_prices.each do |step_price|
      conversion_step = step_price.conversion_step
      step_name = conversion_step.name

      starts_at_from_conversion_step = to_return.dig(step_name, :starts_at)
      ends_at_from_conversion_step = to_return.dig(step_name, :ends_at)

      to_assign = {
        true_share: transform.call(step_price.payout_share, to_return.dig(step_name, :true_share)),
        true_pay: transform.call(step_price.payout_amount, to_return.dig(step_name, :true_pay)),
        affiliate_share: transform.call(step_price.custom_share, to_return.dig(step_name, :affiliate_share)),
        affiliate_pay: transform.call(step_price.custom_amount, to_return.dig(step_name, :affiliate_pay)),
        currency_code: step_price.original_currency,
        true_conv_type: conversion_step.true_conv_type,
        affiliate_conv_type: conversion_step.affiliate_conv_type,
      }

      record_schedule_timestamp = (conversion_step.is_share_rate?(:affiliate) && step_price.custom_share.blank?) ||
        (conversion_step.is_flat_rate?(:affiliate) && step_price.custom_amount.blank?)

      if record_schedule_timestamp
        to_assign[:starts_at] = starts_at_from_conversion_step if starts_at_from_conversion_step.present?
        to_assign[:ends_at] = ends_at_from_conversion_step if ends_at_from_conversion_step.present?
      end

      if schedule = step_price.active_pay_schedule
        to_assign = {
          true_share: transform.call(schedule.true_share, to_assign[:true_share]),
          true_pay: transform.call(schedule.true_pay, to_assign[:true_pay]),
          affiliate_share: transform.call(schedule.affiliate_share, to_assign[:affiliate_share]),
          affiliate_pay: transform.call(schedule.affiliate_pay, to_assign[:affiliate_pay]),
          starts_at: schedule.starts_at,
          ends_at: schedule.ends_at,
          currency_code: schedule.original_currency,
          true_conv_type: to_assign[:true_conv_type],
          affiliate_conv_type: to_assign[:affiliate_conv_type],
        }
      end

      to_return[step_name] = to_assign
    end

    to_return
  end

  def event_contract_signed
    event_contract_signed_at.present? && event_contract_signature.present?
  end

  def event_affiliate_offer?
    event_offer.present?
  end

  def site_info_id
    super || affiliate.site_infos.first&.id
  end

  def approve_related_affiliate_offer
    return unless event_affiliate_offer? && related_offer_id = event_offer.event_info&.related_offer_id

    affiliate_offer = AffiliateOffer.find_or_initialize_by(
      affiliate_id: affiliate_id,
      offer_id: related_offer_id,
    )
    affiliate_offer.approval_status = AffiliateOffer.approval_status_active
    affiliate_offer.save
  end

  def destroy_cancelled
    AffiliateOffer.reappliable
      .where(affiliate_id: affiliate_id, offer_id: offer_id)
      .destroy_all
  end

  def effective_affiliate_pay
    return unless event_affiliate_offer?

    if requested_affiliate_pay.to_f > 0
      requested_affiliate_pay
    else
      event_offer&.affiliate_pay
    end
  end

  private

  def set_defaults
    self.approval_status ||= if offer.need_approval?
      AffiliateOffer.approval_status_pending
    else
      AffiliateOffer.approval_status_active
    end

    return unless event_affiliate_offer? && affiliate&.affiliate_address.present?

    self.shipping_address ||= affiliate.affiliate_address.address_attributes
  end

  def adjust_values
    if event_contract_signed_ip_address_changed?
      self.event_contract_signed_ip_address = event_contract_signed_ip_address.try(:[], 0, 40)
    end

    if cancelled?
      self.event_contract_signed_at = nil
      self.event_contract_signature = nil
      self.event_contract_signed_ip_address = nil
    end

    self.approval_status_changed_at = Time.current if approval_status_changed?
    # TODO: deprecate
    self.activated_at ||= Time.current if active? && approval_status_changed?
  end

  def bulk_set_step_prices_attributes
    return if bulk_conversion_step_id.blank? || bulk_step_price_attributes.blank?

    step_prices.each do |step_price|
      next unless step_price.conversion_step_id == bulk_conversion_step_id.to_i

      step_price.assign_attributes(bulk_step_price_attributes)
    end
  end

  def reset_step_prices
    return unless is_custom_commission_changed?

    if is_custom_commission
      if step_prices.present?
        step_prices.each do |step_price|
          next if step_price.new_record?
          next unless conversion_step = offer.conversion_steps.find_by(id: step_price.conversion_step_id)

          step_price.custom_share = conversion_step.affiliate_share
          step_price.custom_amount = conversion_step.affiliate_pay
          step_price.payout_share = conversion_step.true_share
          step_price.payout_amount = conversion_step.true_pay
        end
      else
        offer.conversion_steps.each do |conversion_step|
          step_prices.build(
            conversion_step_id: conversion_step.id,
            custom_share: conversion_step.affiliate_share,
            custom_amount: conversion_step.affiliate_pay,
            payout_share: conversion_step.true_share,
            payout_amount: conversion_step.true_pay,
          )
        end
      end
    else
      step_prices.map(&:mark_for_destruction)
    end
  end

  def notify
    return if previous_changes[:approval_status].blank?

    notify_application_approval
  end

  def send_email_for_approval_permission
    notification_setting = DotOne::Setup.wl_setup(:new_campaign_notification)

    return unless notification_setting == 'on' && pending?
    return if affiliate.affiliate_users.empty?

    AffiliateMailer.aff_offer_approval_permission_request(self).deliver_later
  end

  def log_changes_for_network
    return unless approval_status_changed?

    affiliate_logs.build(
      agent_type: 'Network',
      agent_id: DotOne::Current.user.is_a?(Network) ? DotOne::Current.user.id : nil,
      notes: "Status changed from #{approval_status_was} to #{approval_status}",
    )
  end
end
