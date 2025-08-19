class CategoryGroupSerializer < ApplicationSerializer
  translatable_attributes(*CategoryGroup.static_translatable_attributes)

  attributes :id, :name, :click_pixels

  has_many :categories, if: :include_categories?

  def include_categories?
    instance_options[:categories]
  end
end
