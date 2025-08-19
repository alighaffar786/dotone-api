class EventOffer < Offer
  include FlexibleTranslatable
  include EventOfferHelpers::Query

  index_name 'offers'
  document_type 'offers'

  has_many :email_templates, as: :owner, inverse_of: :owner, dependent: :destroy

  has_one :event_info, foreign_key: :offer_id, inverse_of: :event_offer, dependent: :destroy

  accepts_nested_attributes_for :event_info, :terms, :default_conversion_step

  before_validation :set_defaults
  after_save :create_relations

  set_local_time_attributes :published_date
  set_flexible_translatable_attributes(short_description: :plain)
  trace_has_one_includes :event_info
  trace_has_many_includes :offer_variants, :conversion_steps, :affiliate_offers

  delegate :is_private, to: :event_info

  scope :public_events, -> { joins(:event_info).where.not(event_infos: { is_private: true }) }
  scope :private_events, -> { joins(:event_info).where(event_infos: { is_private: true }) }

  scope :with_media_categories, -> (*args) {
    includes(event_info: :affiliate_tags).where(affiliate_tags: { id: args.flatten }) if args.present?
  }

  scope :with_event_types, -> (*args) {
    includes(:event_info).where(event_infos: { event_type: args.flatten }) if args.present?
  }

  scope :with_availability_types, -> (*args) {
    includes(:event_info).where(event_infos: { availability_type: args.flatten }) if args.present?
  }

  scope :with_fulfillment_types, -> (*args) {
    includes(:event_info).where(event_infos: { fulfillment_type: args.flatten }) if args.present?
  }

  scope :order_by_status_priority, -> (sort_order = nil) {
    left_outer_joins(:default_offer_variant)
      .select(OfferVariant.status_priority_sql, 'offers.*')
      .order(status_priority: sort_order || :asc, published_date: :desc)
  }

  scope :is_not_private_event, -> {
    joins(:event_info).where(event_infos: {is_private_event: false})
  }

  amoeba do
    nullify :published_date
    prepend name: 'Copy of '

    include_association :brand_image
    include_association :event_info
    include_association :offer_variants
    include_association :conversion_steps
    include_association :email_templates

    customize(-> (original, copy) {
      copy.country_ids = original.country_ids
      copy.category_ids = original.category_ids
      copy.term_ids = original.term_ids

      copy.offer_variants.each do |offer_variant|
        offer_variant.status = OfferVariant.status_draft
      end
    })
  end

  def build_default_offer_variant(*args)
    return if offer_variants.any?

    params = {
      name: 'Default',
      status: OfferVariant.status_active_public,
      is_default: true,
    }
    params = params.merge(*args) if args.present?
    offer_variants.build(params)
  end

  def affiliate_brand_image
    @affiliate_brand_image ||= event_info&.brand_image || brand_image
  end

  def affiliate_pay
    default_conversion_step&.platform_affiliate_pay.to_f
  end

  def max_affiliate_pay
    default_conversion_step&.platform_max_affiliate_pay.to_f
  end

  def forex_affiliate_pay(currency_code = Currency.platform_code)
    default_conversion_step&.forex_affiliate_pay(currency_code).to_f
  end

  def true_pay
    default_conversion_step&.platform_true_pay.to_f
  end

  def forex_true_pay(currency_code = Currency.platform_code)
    default_conversion_step&.forex_true_pay(currency_code).to_f
  end

  def affiliate_pay_flexible?
    !!default_conversion_step&.affiliate_pay_flexible?
  end

  def total_value
    event_info&.value.to_f + affiliate_pay
  end

  def forex_total_value(currency_code = Currency.platform_code)
    event_info&.forex_value(currency_code).to_f + forex_affiliate_pay(currency_code)
  end

  def request_count
    @request_count ||= self[:request_count] || affiliate_offers.non_rejected_for_event.count
  end

  def translation_stats
    current_stats = super
    current_stats.keys.inject({}) do |stats, locale|
      stats[locale] = current_stats[locale].keys.inject({}) do |stat, key|
        stat[key] = current_stats[locale][key] + event_info.translation_stats[locale][key]
        stat
      end
      stats
    end
  end

  private

  def set_defaults
    super
    build_default_offer_variant if default_offer_variant.blank?
  end

  def create_relations
    create_event_info if event_info.blank?
    conversion_steps.create if default_conversion_step.blank?
  end
end
