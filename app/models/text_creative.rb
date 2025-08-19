class TextCreative < DatabaseRecords::PrimaryRecord
  include BecomeCreative
  include Relations::HasCategoryGroups
  include TextCreativeHelpers::Query

  DEAL_SCOPES = ['Entire Store', 'Specific Product']

  attr_accessor :image_cdn

  belongs_to :currency, inverse_of: :text_creatives

  has_many_affiliate_stats
  has_many :text_creative_categories, inverse_of: :text_creative, dependent: :destroy
  has_many :categories, through: :text_creative_categories
  has_many_category_groups through: :categories
  # TODO: Rename to ad_slots
  has_many :simple_ad_slots, class_name: 'AdSlot', inverse_of: :text_creative, dependent: :nullify

  has_one :image, as: :owner, inverse_of: :owner, dependent: :destroy

  accepts_nested_attributes_for :image

  validates :creative_name, presence: true, length: { maximum: 20 }
  validates :title, length: { maximum: 20 }
  validates :content_1, presence: true, length: { maximum: 25 }
  validates :button_text, presence: true, length: { maximum: 10 }
  validates :deal_scope, inclusion: { in: DEAL_SCOPES }
  validates_with CreativeHelpers::Validator::DuplicateTextCreativeName, if: :creative_name_changed?

  before_save :adjust_values
  after_commit :notify_rejected, on: :update

  alias_attribute :client_url, :custom_landing_page

  set_local_time_attributes :active_date_start, :active_date_end, :created_at, :published_at
  set_instance_cache_methods :category_groups, :image_url

  scope :published, -> (*args) {
    right_now = args[0] || Time.now
    where('text_creatives.published_at IS NULL OR text_creatives.published_at < ?', right_now)
  }

  scope :publishable, -> {
    right_now = Time.now
    published(right_now)
      .where('is_infinity_time IS NULL OR is_infinity_time = 1 OR (active_date_start <= ? AND active_date_end >= ?)', right_now, right_now)
  }

  scope :upcoming, -> {
    right_now = Time.now
    published(right_now)
      .where(is_infinity_time: false).where('active_date_start > ?', right_now)
  }

  scope :most_immediate, -> {
    order("IF(text_creatives.active_date_start = '' OR text_creatives.active_date_start IS NULL, 1, 0) ASC")
      .order('text_creatives.active_date_start ASC')
      .order('text_creatives.created_at ASC')
  }

  scope :active_publishable, -> { considered_active.publishable }

  def self.deal_scopes
    DEAL_SCOPES
  end

  def self.inventories(affiliate_id:, category_group_ids: [], offer_ids: [], text_creative_ids: [])
    return [] if affiliate_id.blank?
    return [] if category_group_ids.blank? && offer_ids.blank? && text_creative_ids.blank?

    text_creatives = TextCreative
      .active_publishable
      .joins(:affiliate_offers)
      .where(affiliate_offers: { approval_status: AffiliateOffer.approval_status_active, affiliate_id: affiliate_id })

    text_creatives = if text_creative_ids.present?
      text_creatives.where(id: text_creative_ids)
    elsif offer_ids.present?
      text_creatives.where(offers: { id: offer_ids })
    else
      text_creatives.with_category_groups(category_group_ids)
    end

    text_creatives.distinct
  end

  def self.auto_approvable_inventories(affiliate_id:, category_group_ids: [], offer_ids: [])
    text_creatives = TextCreative
      .active_publishable
      .joins(:offer)
      .merge(NetworkOffer.auto_approvable_offers)
      .where.not(offers: { id: AffiliateOffer.not_cancelled.where(affiliate_id: affiliate_id).select(:offer_id) })

    text_creatives = if offer_ids.present?
      text_creatives.where(offers: { id: offer_ids })
    elsif category_group_ids.present?
      text_creatives.with_category_groups(category_group_ids)
    else
      TextCreative.none
    end

    text_creatives
  end

  def self.catch_all_inventories
    catch_all_offer = DotOne::Setup.catch_all_offer

    return [] if catch_all_offer.blank?

    catch_all_offer.text_creatives.active_publishable
  end

  def image_cdn=(value)
    self.image ||= build_image
    self.image.cdn_url = value
  end

  def currency
    super || Currency.platform
  end

  def currency_id
    super || Currency.platform.id
  end

  def publishable?
    return true if is_infinity_time.blank? && active_date_start.blank? && active_date_end.blank?

    right_now = Time.now
    is_infinity_time == true || (right_now >= active_date_start && right_now <= active_date_end)
  end

  def id_with_name
    "(#{id}) #{creative_name}"
  end

  # Method to return all ad slots that include this text creative
  def ad_slots
    AdSlot.where(affiliate_id: affiliate_offers.pluck(:affiliate_id))
  end

  # Method that returns the appropriate
  # image url for this feed creative.
  def image_url
    image&.cdn_url.presence || cached_offer&.brand_image_url
  end

  def to_token_params(affiliate, catch_any: false)
    affiliate_offer = cached_offer.active_affiliate_offer_for(affiliate, catch_any: catch_any)
    token_params = { affiliate_id: affiliate.id, text_creative_id: id }
    token_params = token_params.merge(affiliate_offer.to_token_params) if affiliate_offer
    token_params
  end

  def to_tracking_url(affiliate, catch_any: false, extra_params: {})
    return custom_landing_page if cached_offer_variant.blank?

    token_params = to_token_params(affiliate, catch_any: catch_any)

    cached_offer_variant.to_tracking_url(
      token_params: token_params,
      extra_params: extra_params.merge(t: custom_landing_page),
    )
  end

  def custom_landing_page
    return unless offer_variant&.deeplinkable?

    self[:custom_landing_page].presence || offer_variant.destination_url.presence || offer.destination_url.presence
  end

  private

  def adjust_values
    self.categories = offer.categories if offer && !categories.any?
    self.coupon_code = coupon_code&.strip
  end

  def notify_rejected
    if rejected? && [TextCreative.status_pending, TextCreative.status_active].include?(status_previously_was)
      TextCreatives::NotifyRejectedJob.perform_later(id)
    end
  end
end
