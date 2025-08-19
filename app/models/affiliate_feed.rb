class AffiliateFeed < DatabaseRecords::PrimaryRecord
  include AppRoleable
  include ConstantProcessor
  include DynamicTranslatable
  include LocalTimeZone
  include DateRangeable
  include Tokens::Tokenable

  STATUSES = ['Published', 'Draft', 'Deleted', 'Scheduled']
  FEED_TYPES = ['New Offer Live', 'Offer Paused', 'Offer Update', 'Special Announcement']

  has_many :affiliate_feed_countries, inverse_of: :affiliate_feed
  has_many :countries, through: :affiliate_feed_countries

  validates :title, :status, presence: true
  validates :published_at, :published_at_local, presence: true, if: :published?
  validates :feed_type, inclusion: { in: FEED_TYPES, allow_nil: true }
  validates :sticky_until, presence: true, if: :sticky?

  before_validation :nullify_country_ids, if: :network?
  before_save :nullify_sticky_until

  define_constant_methods(STATUSES, :status)
  define_constant_methods(FEED_TYPES, :feed_type)

  set_local_time_attributes :published_at, :sticky_until, :republished_at
  set_token_prefix :feed
  set_dynamic_translatable_attributes(title: :plain, content: :html)

  scope :active, -> { where('(sticky is TRUE AND sticky_until >= NOW()) OR sticky is FALSE') }
  scope :recent, -> { order(published_at: :desc, id: :desc) }

  scope :with_stickies, -> (*args) { where(sticky: args) }
  scope :latest_stickies, -> { where('sticky_until >= ?', Time.now).recent }

  scope :with_countries, -> (*args) { where(id: AffiliateFeedCountry.select(:affiliate_feed_id).with_countries(*args)) }

  def formatted_content(render_type = :plain)
    format_content(t_content, render_type)
  end

  def content_offer_ids
    offer_ids = []
    t_content.gsub(/-feed_offer_link_(\d+)-/) { |_| offer_ids << ::Regexp.last_match(1).to_i }
    offer_ids
  end

  def content_image_url
    return if content_offer_ids.blank?

    @content_image_url ||= ImageCreative.active
      .publishable
      .joins(:offer_variant)
      .where(offer_variants: { offer_id: content_offer_ids })
      .with_size('120x60')
      .first&.cdn_url
  end

  # To handle dynamic info calls
  def method_missing(method, *args)
    if method.to_s =~ /^offer_link_/
      key = method.to_s.gsub(/^offer_link_/, '')
      val = generate_offer_link(key)
      return val.to_s
    end
    super
  end

  ##
  # Used to print out offer link with ID and Name
  # on Feeds for Affiliates to the affiliate detail page.
  # Token served is -feed_offer_link_1234- where 1234 is an offer id
  # Please refer to method_missing.
  def generate_offer_link(offer_id)
    return unless offer = NetworkOffer.active.find_by(id: offer_id)

    "<a href='#{DotOne::ClientRoutes.affiliates_offer_url(offer_id)}'>#{offer.id_with_name}</a>"
  end

  def sticky_expired?
    !!(sticky_until&.< Time.now)
  end

  private

  def nullify_sticky_until
    return if sticky?

    self.sticky_until = nil
  end

  def nullify_country_ids
    self.country_ids = []
  end
end
