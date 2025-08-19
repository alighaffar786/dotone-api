class AffiliateTag < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include StaticTranslatable

  NAME_FOR_PARKING_OFFER_CATEGORY = '_parking-offer-category-'
  NAME_FOR_AFFILIATE_REFERRAL = 'Affiliate Referral Target'
  PROSPECT_TYPES = ['Advertiser Prospect', 'Affiliate Prospect']
  FEATURED_OFFER = '300x125 Offer Slot'

  MEDIA_CATEGORY_COLORS = {
    blog: '#FF9933',
    youtube: '#FF3300',
    weibo: '#FF3300',
    xiaohongshu: '#FF3300',
    youku: '#FF3300',
    instagram: '#9966FF',
    twitch: '#9966FF',
    facebook: '#3366CC',
    bilibili: '#3366CC',
    telegram: '#3366CC',
    metacafe: '#3366CC',
    tiktok: '#66CCCC',
    twitter: '#66CCCC',
    vimeo: '#66CCCC',
    line: '#339900',
    whatsapp: '#339900',
    snapchat: '#CCCC00',
    other_sms_chat: '#FF66FF',
    other_social_media: '#FF66FF',
    other_video_content: '#FF66FF',
  }.freeze

  TAG_TYPES = {
    blog_tag: 'BlogTag', # TODO change to Blog
    event_media_category: 'Event Media Category',
    group_tag: 'Group',
    target_device_brand_name: 'Target Device Brand Name',
    target_device_model_name: 'Target Device Model Name',
    target_device_os_version: 'Target Device OS Version',
    target_device_type: 'Target Device Type',
    media_category: 'Media Category',
    media_restriction: 'Media Restriction',
    system_tag: 'System',
    top_network_offer: 'Top Network Offer',
    top_traffic_source: 'Top Traffic Source',
    traffic_channel: 'Traffic Channel',
  }

  # Super/Sub category relationship
  belongs_to :parent_category, inverse_of: :child_categories, class_name: 'AffiliateTag'

  has_many :child_categories, class_name: 'AffiliateTag', foreign_key: 'parent_category_id', inverse_of: :parent_category, dependent: :nullify
  has_many :owner_has_tags, inverse_of: :affiliate_tag, dependent: :destroy
  has_many :owners, through: :owner_has_tags
  has_many :offer_tags, -> { where(owner_type: 'Offer') }, class_name: 'OwnerHasTag', inverse_of: :affiliate_tag
  has_many :offers, through: :owner_has_tags, source: :owner, source_type: 'Offer'
  has_many :variant_tags, -> { where(owner_type: 'OfferVariant') }, class_name: 'OwnerHasTag', inverse_of: :affiliate_tag
  has_many :offer_variants, through: :owner_has_tags, source: :owner, source_type: 'OfferVariant'
  has_many :blog_contents, through: :owner_has_tags, source: :owner, source_type: 'BlogContent'
  has_many :event_infos, through: :owner_has_tags, source: :owner, source_type: 'EventInfo'
  has_many :site_info_tags, inverse_of: :affiliate_tag, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :tag_type }

  define_constant_methods(PROSPECT_TYPES, :name, prefix: :prospect_type)

  set_static_translatable_attributes :name, :media_category_name, :media_restriction_name,
    :top_network_offer_name, :top_traffic_source_name, :event_media_category_name

  scope :all_tag_types, -> { select('DISTINCT tag_type').where.not(tag_type: nil) }

  scope :with_affiliate_tags, -> (*args) {
    if args[0].present?
      values = args.flatten.map { |x| x.try(:id) || x }
      where(id: values)
    end
  }

  scope :parking_offer_category, -> (*args) {
    if args[0].present?
      category = args[0].try(:id) || args[0]
      where('name LIKE ?', "#{NAME_FOR_PARKING_OFFER_CATEGORY}#{category}")
    else
      where('name LIKE ?', "#{NAME_FOR_PARKING_OFFER_CATEGORY}%")
    end
  }

  default_scope -> { order(updated_at: :desc) }

  scope :default_media_restrictions, -> { media_restrictions.where(name: 'Adult Ads') }
  scope :children_media_categories, -> { media_categories.where.not(parent_category_id: nil) }
  scope :parent_media_categories, -> { media_categories.where(parent_category_id: nil) }
  scope :content_target_channels, -> { traffic_channels.where(name: ['Facebook', 'Instagram', 'Blog']) }
  scope :video_target_channels, -> { traffic_channels.where(name: ['Youtube', 'Vimeo', 'TikTok']) }
  scope :chat_target_channels, -> { traffic_channels.where(name: ['LINE', 'Whatsapp', 'Snapchat']) }
  scope :for_offer_slots, -> { where(name: FEATURED_OFFER) }
  scope :target_devices, -> { where(tag_type: tag_type_target_devices) }

  scope :like, -> (*args) {
    where('id LIKE :q OR name LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  TAG_TYPES.each do |name, tag_type|
    scope(name.to_s.pluralize, -> { where(tag_type: tag_type) })

    define_singleton_method "tag_type_#{name}" do
      tag_type
    end

    define_method "#{name}?" do
      self.tag_type == tag_type
    end

    define_method "#{name}_name" do
      return unless send("#{name}?")

      self.name
    end
  end

  def media_category_color
    return nil unless event_media_category?
    MEDIA_CATEGORY_COLORS[name.to_s.downcase.to_sym] || '#000000'
  end

  def self.create_parking_offer_category(category)
    create(name: "#{NAME_FOR_PARKING_OFFER_CATEGORY}#{category.id}")
  end

  def self.get_advertiser_prospect
    find_or_create_by(name: prospect_type_advertiser_prospect)
  end

  def self.get_affiliate_prospect
    find_or_create_by(name: prospect_type_affiliate_prospect)
  end

  def self.get_affiliate_referral
    system_tags.find_by(name: NAME_FOR_AFFILIATE_REFERRAL)
  end

  def self.tag_type_target_devices
    [
      tag_type_target_device_type,
      tag_type_target_device_model_name,
      tag_type_target_device_brand_name,
      tag_type_target_device_os_version,
    ]
  end

  def t_name(locale = nil)
    if media_category?
      t_media_category_name(locale)
    elsif media_restriction?
      t_media_restriction_name(locale)
    elsif top_network_offer?
      t_top_network_offer_name(locale)
    elsif top_traffic_source?
      t_top_traffic_source_name(locale)
    elsif event_media_category?
      t_event_media_category_name(locale)
    else
      name
    end
  end

  def is_for_category_parking?
    name.match(/#{NAME_FOR_PARKING_OFFER_CATEGORY}/).present?
  end

  def category_parking_id
    return unless is_for_category_parking?

    name.gsub(NAME_FOR_PARKING_OFFER_CATEGORY, '')
  end

  def category
    return unless is_for_category_parking?
    @category ||= Category.find_by(id: category_parking_id)
  end

  def blog_tag_path(blog)
    path = ['/']
    path << blog.path
    customized_name = [id, name].join(' ').parameterize
    path << "/tag/tag-#{customized_name}.html"
    path.join
  end

  def most_popular_tag?
    name == 'Most Popular'
  end

  def ad_link_tag?
    ['Loyalty', 'Promotion', 'Text Content'].include?(parent_category&.name)
  end

  def integration_tag?
    ['TikTok', 'Youtube', 'Facebook', 'Instagram'].include?(name)
  end
end
