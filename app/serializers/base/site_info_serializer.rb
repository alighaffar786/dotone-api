class Base::SiteInfoSerializer < ApplicationSerializer
  def parent_category_id
    object.media_category&.parent_category_id
  end
end
