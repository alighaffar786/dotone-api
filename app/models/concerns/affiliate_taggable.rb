module AffiliateTaggable
  extend ActiveSupport::Concern

  included do
    has_many :owner_has_tags, as: :owner, inverse_of: :owner, dependent: :destroy
    has_many :affiliate_tags, through: :owner_has_tags

    accepts_nested_attributes_for :affiliate_tags

    scope :with_tag_ids, -> (*args) {
      if args[0].present?
        joins(:affiliate_tags).where(affiliate_tags: { id: args.flatten })
      end
    }

    scope :with_tag_names, -> (*args) {
      if args[0].present?
        joins(:affiliate_tags).where(affiliate_tags: { name: args.flatten })
      end
    }
  end

  def affiliate_tag_ids=(value)
    return if value.blank?

    value = value.split(',') if value.is_a?(String)
    super(affiliate_tag_ids + value)
  end

  def tagging_for(tag_type)
    owner_has_tags
      .joins(:affiliate_tag)
      .where(affiliate_tags: { tag_type: tag_type })
  end
end
