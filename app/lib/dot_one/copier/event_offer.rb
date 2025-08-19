class DotOne::Copier::EventOffer < DotOne::Copier::Offer
  private

  def image_object_path
    "#{Rails.env}/dotone/event_offer/affiliate_user/#{user.id}/"
  end

  def after_save
    super

    attributes = offer.event_info.attributes.except('created_at', 'updated_at', 'id', 'offer_id', 'related_offer_id')
    result.event_info.update(attributes)

    result.event_info.images = offer.event_info.images.map do |image|
      new_image = image.dup
      new_image.assign_attributes(cdn_url: duplicate_file(image.cdn_url))
      new_image
    end
    result.event_info.owner_has_tags = offer.event_info.owner_has_tags.map(&:dup)
    result.event_info.event_has_category_groups = offer.event_info.event_has_category_groups.map(&:dup)
    result.event_info.translations = offer.event_info.translations.map do |translate|
      Translation.new(translate.attributes.except('id', 'created_at', 'updated_at', 'unique_id'))
    end
  end
end
