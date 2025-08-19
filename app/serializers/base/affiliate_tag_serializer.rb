class Base::AffiliateTagSerializer < ApplicationSerializer
  translatable_attributes(*AffiliateTag.static_translatable_attributes)

  conditional_attributes :most_popular_tag?, if: :include_most_popular_tag?

  def key
    object.name
  end

  def include_most_popular_tag?
    instance_options[:tag_type] == AffiliateTag.tag_type_top_network_offer
  end
end
