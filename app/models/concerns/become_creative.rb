module BecomeCreative
  extend ActiveSupport::Concern

  STATUSES = ['Active', 'Pending', 'Paused', 'Rejected', 'Suspended'].freeze

  included do
    include ConstantProcessor
    include ModelCacheable
    include LocalTimeZone
    include NameHelper
    include Scopeable
    include Traceable
    include Relations::AffiliateStatAssociated

    has_many :creatives, as: :entity, dependent: :destroy
    has_many :offer_variants, through: :creatives, validate: false
    has_many :offers, through: :offer_variants
    has_many :affiliate_offers, through: :offers
    has_many :affiliates, through: :affiliate_offers

    has_one :creative, -> { joins(:offer_variant).order('offer_variants.is_default DESC') }, as: :entity
    has_one :offer_variant, -> { order(is_default: :desc) }, through: :creative
    has_one :offer, through: :offer_variant
    has_one :network, through: :offer

    validate :validate_active_range_pass_time
    validates :status, inclusion: { in: STATUSES }
    validates_with CreativeHelpers::Validator::DestinationUrlMatchDomain

    define_constant_methods STATUSES, :status
    set_instance_cache_methods :offer_variant

    before_validation :set_defaults
    before_save :adjust_values

    scope_by_offer 'offer_variants.offer_id'
    scope_by_network 'offers.network_id'

    scope :with_active_offers, -> {
      joins(:offer_variant).where(offer_variants: { status: OfferVariant.status_considered_active })
    }

    scope :considered_active, -> { active.with_active_offers }

    scope :considered_non_rejected, -> { where.not(status: status_considered_rejected) }
    scope :rejected_or_expired, -> { where(status: status_considered_rejected) }
    scope :with_internal, -> (*args) { where(internal: args[0]) if scope_arguments_valid?(args) }
    scope :order_by_recent, -> { order(updated_at: :desc, created_at: :desc) }

    scope :with_offer_variants, -> (*args) {
      joins(:offer_variants).where(offer_variants: { id: args[0] }) if scope_arguments_valid?(args)
    }

    scope :with_locales, -> (*args, **options) {
      values = args.flatten.compact.join('|')

      return if values.blank?

      if options[:exact]
        where('locales REGEXP ?', values)
      else
        where('locales REGEXP ? OR locales is NULL OR locales = cast("[]" as JSON)', values)
      end
    }

    scope :order_by_status, -> {
      order(Arel.sql("FIELD(#{table_name}.status, '#{statuses_sorted.join('\',\'')}')"))
    }

    def self.statuses(user_role = nil)
      if user_role == :network
        [status_paused, status_suspended]
      else
        STATUSES
      end
    end
  end

  module ClassMethods
    def scope_arguments_valid?(args)
      args.present? && args[0].present?
    end

    def status_considered_rejected
      [
        status_rejected,
        status_suspended,
      ]
    end

    def statuses_sorted
      [
        status_pending,
        status_active,
        status_paused,
        status_suspended,
        status_rejected,
      ]
    end
  end

  def offer_id=(value)
    self.offer_variant_id = OfferVariant.default.find_by(offer_id: value)&.id
  end

  def offer_id
    offer&.id
  end

  def offer_variant_id=(value)
    self.offer_variant_ids = [value]
    super(value)
  end

  def offer_variant_id
    offer_variant&.id
  end

  def active_range_exists?
    active_date_start.present? && active_date_end.present?
  end

  def ongoing?(time_zone)
    return false if is_infinity_time? || !active_range_exists?

    today = time_zone.from_utc(Time.now.utc).to_date
    start_at = active_date_start_local(time_zone).to_date
    end_at = active_date_end_local(time_zone).to_date

    start_at <= today && end_at >= today
  end

  def locales
    (super.presence.to_a).sort
  end

  def locales=(value)
    super([value].flatten & LOCALES)
  end

  def set_defaults
    self.status ||= self.class.status_pending
  end

  def adjust_values
    self.active_date_start = nil if is_infinity_time?
    self.active_date_end = nil if is_infinity_time?
    self.status_reason = nil unless rejected?
  end

  def validate_active_range_pass_time
    return if is_infinity_time?
    return unless active_date_start_changed? || active_date_end_changed?

    now = Time.now.utc

    if active_date_start.blank? || active_date_end.blank? ||
        new_record? && (active_date_start < now || active_date_end < now) ||
        active_date_end < active_date_start
      errors.add(:active_date_start, :range_cannot_be_in_the_past)
    end
  end

  def cached_offer
    cached_offer_variant&.cached_offer
  end
end
