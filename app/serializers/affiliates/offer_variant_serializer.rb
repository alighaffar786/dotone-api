class Affiliates::OfferVariantSerializer < Base::OfferVariantSerializer
  attributes :id, :offer_id, :is_default, :status, :active?, :can_config_url, :full_name, :destination_url, :destination_urls

  conditional_attributes :tracking_url

  def tracking_url?
    instance_options[:affiliate_offer_id].present?
  end

  def tracking_url
    object.to_tracking_url(
      token_params: {
        affiliate_id: current_user.id,
        affiliate_offer_id: instance_options[:affiliate_offer_id],
      },
    )
  end
end
