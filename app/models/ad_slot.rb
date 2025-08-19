class AdSlot < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include LocalTimeZone
  include ModelCacheable
  include Relations::AffiliateAssociated
  include Relations::HasCategoryGroups

  STATUSES = ['Active', 'Archived']
  DISPLAY_FORMATS = ['Image & Text', 'Image Only', 'Text Only']

  self.primary_key = :id

  belongs_to :text_creative, inverse_of: :simple_ad_slots

  has_many :ad_slot_offers, inverse_of: :ad_slot, dependent: :destroy
  has_many :offers, through: :ad_slot_offers
  has_many :ad_slot_category_groups, inverse_of: :ad_slot, dependent: :destroy
  has_many_category_groups through: :ad_slot_category_groups

  validates :name, uniqueness: { scope: :affiliate_id }
  validates :width, :height, presence: true
  validates_with AdSlotHelpers::Validator::OneInventorySelectionMustExist

  before_validation :set_defaults
  before_create :generate_id

  mount_uploader :client_html, AdSlotUploader

  define_constant_methods(STATUSES, :status)
  define_constant_methods(DISPLAY_FORMATS, :display_format)
  set_local_time_attributes :created_at
  set_instance_cache_methods :category_groups, :offers

  scope :with_dimensions, -> (*args) {
    if args.present?
      result = nil

      args.flatten.each do |dimension|
        width, height = convert_dimensions(dimension)
        result = if result
          result.or(where(width: width, height: height))
        else
          where(width: width, height: height)
        end
      end

      result
    end
  }

  def self.dimension_selections
    [
      '468x60',
      '728x90',
      '750x300',
      '300x250',
      '364x90',
      '160x600',
      '120x600',
      '180x280',
    ]
  end

  def self.dimension_with_no_contents
    ['180x280', '468x60', '728x90']
  end

  def self.convert_dimensions(value)
    value.to_s.split('x')
  end

  def dimensions
    [width, height].reject(&:blank?).join('x')
  end

  def dimensions=(value)
    self.width, self.height = AdSlot.convert_dimensions(value)
  end

  def category_group_ids=(value)
    super(value.to_a.take(5))
  end

  def offer_ids=(value)
    super(value.to_a.take(5))
  end

  def inventory_type
    if text_creative_id.present?
      'Creative'
    elsif offers.any?
      'Offer'
    else
      'Category Group'
    end
  end

  def code
    DotOne::ScriptGenerator.generate_ad_slot_script(self)
  end

  def mark_as_archived
    self.status = AdSlot.status_archived
    save(validate: false)
  end

  def current_inventories
    ckey = DotOne::Utils.to_cache_key(self)
    DotOne::Cache.fetch(ckey)
  end

  private

  def generate_id
    self.id = DotOne::Utils.generate_token
  end

  def set_defaults
    self.status ||= AdSlot.status_active
    self.display_format ||= AdSlot.display_format_image_and_text
  end
end
