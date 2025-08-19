class Teams::OfferVariant::TestUrlSerializer < Base::OfferVariantSerializer
  attributes :id, :status, :full_name, :test_tracking_url, :offer_id

  def test_tracking_url
    object.to_test_tracking_url
  end
end
