class Base::EventOfferSerializer < ApplicationSerializer
  forexable_attributes(*EventOffer.forexable_attributes, :affiliate_pay, :true_pay, :total_value)
  local_time_attributes(*EventOffer.local_time_attributes)
  translatable_attributes(*EventOffer.dynamic_translatable_attributes)
  translatable_attributes(*EventOffer.flexible_translatable_attributes)

  def brand_image_url
    object.brand_image&.cdn_url
  end

  def approval_status
    return unless object.respond_to?(:approval_status)

    object.approval_status
  end
end
