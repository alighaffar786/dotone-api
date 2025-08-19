require 'uri'

class OfferVariant < DatabaseRecords::PrimaryRecord
  include AffiliateTaggable
  include ConstantProcessor
  include DynamicTranslatable
  include ModelCacheable
  include NameHelper
  include Scopeable
  include StaticTranslatable
  include Traceable
  include DotOne::I18n
  include OfferVariantHelpers::Query
  include Relations::AffiliateStatAssociated
  include Relations::OfferAssociated

  STATUSES = [
    'Active',
    'Active Public',
    'Active Private',
    'Draft',
    'Paused',
    'Suspended',
    'Fulfilled',
    'Completed',
  ].freeze

  VARIANT_TYPES = [
    'Home Page',
    'Designated Page',
    'Registration Page',
  ].freeze

  attr_accessor :should_notify_status_change

  belongs_to_offer touch: true

  has_many_affiliate_stats

  has_many :creatives, inverse_of: :offer_variant, dependent: :destroy

  has_many :creative_for_images, -> { where(entity_type: 'ImageCreative') }, class_name: 'Creative', dependent: :destroy
  has_many :image_creatives, through: :creative_for_images, dependent: :destroy

  has_many :creative_for_texts, -> { where(entity_type: 'TextCreative') }, class_name: 'Creative', dependent: :destroy
  has_many :text_creatives, through: :creative_for_texts, dependent: :destroy

  has_many :orders, inverse_of: :offer_variant, dependent: :nullify
  has_many :variant_tags, -> { where(owner_type: 'OfferVariant') }, class_name: 'OwnerHasTag', foreign_key: :owner_id

  has_many :affiliate_tags, through: :variant_tags
  has_many :system_tags, through: :owner_has_tags

  has_one :offer_cap, inverse_of: :offer_variant, dependent: :destroy
  has_one :network, through: :offer

  accepts_nested_attributes_for :offer_cap, reject_if: -> (attrs) { attrs['id'].blank? && attrs['cap_type'].blank? }

  validates :offer_id, presence: true, on: :update # on creation, we will set it on callbacks
  validates :is_default, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: [:offer_id, :variant_type], case_sensitive: true }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :variant_type, presence: true, inclusion: { in: VARIANT_TYPES }
  validates :destination_url, presence: true

  before_save :cleanup_deeplink_parameters
  after_save :make_sure_one_default, :touch_suspended_at
  after_destroy :make_sure_one_default
  after_commit :notify_status_change, on: :update

  serialize :deeplink_parameters
  set_dynamic_translatable_attributes(name: :plain, description: :plain)
  set_static_translatable_attributes :variant_type
  set_instance_cache_methods :affiliate_tags, :device_filters, :image_creatives, :text_creatives

  define_constant_methods(STATUSES, :status)
  define_constant_methods(VARIANT_TYPES, :variant_type)

  scope_by_network 'offers.network_id'

  scope :default, -> { where(is_default: true) }
  scope :not_default, -> { where(is_default: false) }
  scope :not_suspended, -> { where.not(status: status_suspended) }
  scope :active, -> { where(status: status_considered_active) }
  scope :considered_active_public, -> { where(status: status_considered_active_public) }
  scope :recently_updated, -> { order(updated_at: :desc) }

  scope :order_by_status, -> {
    order(Arel.sql("FIELD(offer_variants.status, '#{statuses_sorted.join('\',\'')}')"))
  }

  delegate :multi_conversion_point?, :single_conversion_point?, :deeplinkable?, to: :offer

  # TODO cache later on
  def self.for_referral
    # AffiliateTag.get_affiliate_referral.offer_variants.active.sample
    OfferVariant.cached_find(1210)
  end

  def self.statuses
    [
      status_active_public,
      status_active_private,
      status_paused,
      status_suspended,
      status_fulfilled,
    ]
  end

  # Order matters
  def self.statuses_sorted
    [
      status_draft,
      status_active,
      status_active_public,
      status_active_private,
      status_fulfilled,
      status_completed,
      status_paused,
      status_suspended,
    ]
  end

  def self.status_considered_positive
    [
      status_active,
      status_active_public,
      status_active_private,
      status_fulfilled,
      status_completed,
    ]
  end

  def self.status_considered_negative
    statuses_sorted - status_considered_positive
  end

  def self.event_statuses
    [
      status_draft,
      status_active,
      status_fulfilled,
      status_completed,
    ]
  end

  def self.status_considered_public
    [
      status_active,
      status_active_public,
    ]
  end

  def self.status_considered_active
    [
      status_active,
      status_active_public,
      status_active_private,
    ]
  end

  def self.status_considered_active_public
    [
      status_active,
      status_active_public,
    ]
  end

  def self.status_considered_active_fulfilled
    [
      status_active,
      status_active_public,
      status_active_private,
      status_fulfilled,
    ]
  end

  def self.status_considered_unpublished
    [
      status_paused,
      status_suspended,
      status_fulfilled,
    ]
  end

  def self.bulk_touch(id_collection)
    return if id_collection.blank?

    id_collection.uniq.each_slice(500) do |group_ids|
      OfferVariant.where(id: group_ids).update_all(updated_at: Time.now)
    end
  end

  def for_network_offer?
    offer&.network_offer?
  end

  def active?
    OfferVariant.status_considered_active.include?(status)
  end

  def active_public?
    OfferVariant.status_considered_active_public.include?(status)
  end

  def considered_positive?
    OfferVariant.status_considered_positive.include?(status)
  end

  def siblings
    @siblings ||= offer.offer_variants.where.not(id: id).to_a
  end

  def alternatives
    @alternatives ||= offer.categories.flat_map do |category|
      AffiliateTag.parking_offer_category(category).flat_map do |tag|
        tag
          .offer_tags
          .ordered
          .map(&:offer)
          .map { |x| x.default_offer_variant&.active? ? x.default_offer_variant : nil }
      end
    end
      .compact.uniq
  end

  def full_name(locale = nil)
    [t_variant_type(locale), t_name(locale)].reject(&:blank?).join(' - ')
  end

  def id_with_name(locale = nil)
    "(#{id}) #{full_name(locale)}"
  end

  def destination_url
    self[:destination_url] || offer.destination_url
  end

  def name_to_trace
    "(OFFER VARIANT: #{id_with_name}) of (OFFER: #{offer.id_with_name})"
  end

  def published_image_creatives(options = {})
    image_creatives
      .with_size(options[:size])
      .with_locales(options[:locale])
      .publicly
      .publishable
      .active
      .order_by_recent
  end

  def download_image_creatives(options = {})
    image_creatives = published_image_creatives(options)
    input = DotOne::Utils::File.create_dir("offer-variant-#{id}")
    output = DotOne::Utils::File.generate_filename("images-#{id}-#{options[:size] || 'all'}.zip")

    files = image_creatives.map do |creative|
      creative.download_image(input)
    end.compact

    if files.empty?
      output = nil
    else
      DotOne::Utils::ZipFile.new(input, output).write
      DotOne::Utils::File.delete_dir(input)
    end

    { output: output, image_creatives: image_creatives }
  rescue StandardError
    {}
  end

  def target_device
    affiliate_tags.first&.name
  end

  ## This method collects all device filters and return a hash
  # Ex: {:allow => {:target_device_type=>["Desktop"], :target_device_model=>[], :target_device_brand=>[], :target_device_os_version=>[]},
  #      :deny =>  {:target_device_type=>[], :target_device_model=>[], :target_device_brand=>[], :target_device_os_version=>[]}
  # }
  def device_filters
    filters = [:allow, :deny].each_with_object({}) do |key, hash|
      hash[key] = AffiliateTag.tag_type_target_devices.each_with_object({}) do |subkey, subhash|
        converted_key = subkey.delete("\s").underscore.to_sym
        subhash[converted_key] = []
      end
    end

    OwnerHasTag.access_types.each do |tag_type|
      variant_tags.where(access_type: tag_type).each do |vt|
        aff_tag = vt.affiliate_tag rescue nil
        filters[tag_type.to_sym][aff_tag.tag_type.delete("\s").underscore.to_sym] << aff_tag.name if aff_tag.present?
      end
    end

    filters
  end

  ##
  # Method to return the domain portion of
  # its Destination URL.
  def destination_domain
    uri = URI.parse(destination_url) rescue nil
    return if uri.blank?

    uri = URI.parse("http://#{destination_url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def to_tracking_url(token_params: {}, extra_params: {})
    token = DotOne::Track::Token.new(token_params.merge(offer_variant_id: id))
    DotOne::Track::Routes.track_clicks_url(
      extra_params.merge(id: id, token: token.encrypted_string),
    )
  end

  def to_test_tracking_url(token_params: {}, extra_params: {})
    to_tracking_url(
      token_params: token_params.merge(affiliate_id: DotOne::Setup.test_affiliate_id),
      extra_params: extra_params.merge(subid_1: 'test'),
    )
  end

  def offer_in_adult_category?
    offer.in_adult_category?
  end

  def active_status_changed?
    (
      OfferVariant.status_considered_active.include?(status) && OfferVariant.status_considered_unpublished.include?(status_previously_was)
    ) || (
      OfferVariant.status_considered_unpublished.include?(status) && OfferVariant.status_considered_active.include?(status_previously_was)
    )
  end

  def destination_urls
    cached_offer.destination_urls
  end

  private

  # make sure there is one variant set as default
  def make_sure_one_default
    if is_default?
      sql = <<-SQL
        UPDATE offer_variants
        SET is_default = 0
        WHERE offer_id = #{offer_id} AND id <> #{id}
      SQL
      OfferVariant.connection.execute(sql)
    elsif offer.offer_variants.default.blank?
      sql = <<-SQL
        UPDATE offer_variants
        SET is_default = 1
        WHERE offer_id = #{offer_id} LIMIT 1
      SQL
      OfferVariant.connection.execute(sql)
    end
    offer.reload rescue nil
  end

  def touch_suspended_at
    return unless is_default && suspended? && status_previously_was != OfferVariant.status_suspended

    offer.touch(:suspended_at)
  end

  def cleanup_deeplink_parameters
    return unless deeplink_parameters.present? && deeplink_parameters.is_a?(Array)

    self.deeplink_parameters = deeplink_parameters.reject { |hash| hash['key'].blank? && hash['value'].blank? }
  end

  def notify_status_change
    return unless should_notify_status_change && active_status_changed? && is_default? && offer.network_offer? && status_previously_changed?

    if OfferVariant.status_considered_active.include?(status_previously_was)
      offer.offer_variants.active.where.not(id: id).update_all(status: status)
    end

    NetworkOffers::NotifyStatusChangedJob.perform_later(offer_id)
  end
end
