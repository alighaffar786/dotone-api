class Public::EventOfferSerializer < ApplicationSerializer
  translatable_attributes(*EventOffer.dynamic_translatable_attributes)
  
  attributes :id, :name, :brand_image_url, :images, :total_value, :published_date, :category_groups, :media_category

  def images
    object.event_info.images.map(&:cdn_url)
  end

  def category_groups
    object.event_info.category_groups.map(&:name)
  end

  def media_category
    tag = object.event_info&.media_category
    return nil unless tag.present?
    {
      name: tag.name,
      color: tag.media_category_color
    }
  end
end
