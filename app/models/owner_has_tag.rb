class OwnerHasTag < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Owned

  ACCESS_TYPES = ['allow', 'deny']

  belongs_to_owner touch: true
  belongs_to :affiliate_tag, inverse_of: :owner_has_tags, touch: true

  AffiliateTag::TAG_TYPES.keys.each do |name|
    belongs_to name, -> { send(name.to_s.pluralize) }, class_name: 'AffiliateTag', foreign_key: :affiliate_tag_id
  end

  validates :affiliate_tag_id, uniqueness: { scope: [:owner_type, :owner_id] }

  before_create :set_display_order

  define_constant_methods ACCESS_TYPES, :access_type

  scope :ordered, -> { order(display_order: :asc) }

  private

  def set_display_order
    self.display_order ||= OwnerHasTag.where(affiliate_tag_id: affiliate_tag_id).maximum(:display_order).to_i + 1
  end
end
