class V2::Affiliates::OfferVariantSerializer < Base::OfferVariantSerializer
  include DotOne::Api::V2Helper

  attributes :id, :name, :description, :status, :commission_range, :is_default, :conversion_point, :tracking_url

  has_many :conversion_points

  def conversion_points
    object.offer.ordered_conversion_steps
  end

  def commission_range
    commissions = object.offer.commission_details(affiliate: current_user, currency_code: currency_code)

    to_commission_range(commissions)
  end

  def conversion_point
    object.offer.conversion_point
  end

  def tracking_url
    affiliate_offer&.to_tracking_url
  end

  def affiliate_offer
    instance_options[:affiliate_offers][object.offer_id]
  end
end
