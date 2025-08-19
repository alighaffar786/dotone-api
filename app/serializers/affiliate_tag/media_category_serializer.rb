class AffiliateTag::MediaCategorySerializer < Base::AffiliateTagSerializer
  attributes :id, :name, :key, :tag_type, :parent_category_id, :parent_category_key, :parent_category_name

  has_many :child_categories, serializer: AffiliateTag::MediaCategorySerializer, if: :include_children?

  def parent_category_key
    object.parent_category&.name
  end

  def parent_category_name
    object.parent_category&.t_name
  end

  def include_children?
    !object.parent_category_id && instance_options[:children]
  end
end
