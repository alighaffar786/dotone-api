class EventInfo < DatabaseRecords::PrimaryRecord
  include AffiliateTaggable
  include ConstantProcessor
  include DynamicTranslatable
  include StaticTranslatable
  include Forexable
  include LocalTimeZone
  include Traceable
  include Relations::HasCategoryGroups
  include Tokens::Tokenable

  AVAILABILITY_TYPES = [
    'Site Wide',
    'Specific Item',
  ].freeze

  EVENT_TYPES = [
    'Backlinks',
    'Creative Post',
    'Customization',
    'Group Buy',
    'Invite Only',
    'Product Sampling',
    'Text Review',
    'Video Review',
  ].freeze

  FULFILLMENT_TYPES = [
    'In-Person',
    'Delivery',
    'Self Purchase',
  ].freeze

  POPULARITY_UNITS = [
    'Accumulate Traffic',
    'Daily UU',
    'Fans',
    'Followers',
    'Likes',
    'Site Rank',
    'Subscribers',
  ].freeze

  MAX_ALLOWED_IMAGES = 6

  belongs_to :event_offer, foreign_key: :offer_id, inverse_of: :event_info, touch: true
  belongs_to :related_offer, class_name: 'Offer', foreign_key: :related_offer_id

  has_many :images, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :event_has_category_groups, inverse_of: :event_info, dependent: :destroy
  has_many_category_groups through: :event_has_category_groups

  has_one :brand_image, class_name: 'Image', as: :owner, inverse_of: :owner, dependent: :destroy
  has_one :event_tag, -> { left_outer_joins(:affiliate_tag).where(affiliate_tags: AffiliateTag.event_media_categories) }, class_name: 'OwnerHasTag', as: :owner
  has_one :event_media_category, through: :event_tag, source: :event_media_category
  has_one :media_category, through: :event_media_category, source: :parent_category

  accepts_nested_attributes_for :images, reject_if: -> (attrs) { attrs['cdn_url'].blank? }, allow_destroy: true

  validates :offer_id, presence: true, on: :update
  validates :coordinator_email, format: { with: REGEX_EMAIL }, allow_blank: true

  before_validation :set_defaults

  alias_attribute :is_private, :is_private_event

  set_token_prefix :event_info
  set_forexable_attributes :value
  set_local_time_attributes :applied_by, :selection_by, :submission_by, :evaluation_by, :published_by
  set_dynamic_translatable_attributes(
    details: :html,
    supplement_notes: :plain,
    event_contract: :html,
    event_requirements: :html,
    instructions: :html,
    keyword_requirements: :plain,
  )
  set_static_translatable_attributes(:event_type, cap_type: 'predefined.models.event_info.event_type')

  define_constant_methods AVAILABILITY_TYPES, :availability_type
  define_constant_methods EVENT_TYPES, :event_type
  define_constant_methods FULFILLMENT_TYPES, :fulfillment_type
  define_constant_methods POPULARITY_UNITS, :popularity_unit

  amoeba do
    include_association :images

    customize(-> (orig_info, new_info) {
      new_info.category_group_ids = orig_info.category_group_ids
      new_info.affiliate_tag_ids = orig_info.affiliate_tag_ids
    })
  end

  def self.timeline_columns
    [
      'applied_by', 'selection_by', 'submission_by', 'evaluation_by', 'published_by'
    ]
  end

  def event_media_category_id
    event_media_category&.id
  end

  def event_media_category_id=(value)
    self.event_media_category = AffiliateTag.event_media_categories.find(value)
  end

  def quota
    super.to_i
  end

  def days_left_to_apply
    (applied_by.to_date - Date.today).to_i
  rescue StandardError
    0
  end

  def active_timeline
    return @active_timeline if @active_timeline.present?

    EventInfo.timeline_columns.each do |column|
      date = send(column)
      next if date.blank?

      if date.to_date >= Time.now.utc.to_date
        @active_timeline = column
        break
      end
    end

    @active_timeline
  end

  private

  def set_defaults
    self.availability_type ||= EventInfo.availability_type_site_wide
  end
end
