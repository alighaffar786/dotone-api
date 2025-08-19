class AffiliateStats::ClickJob < TrackingJob
  def perform(offer_variant_id, tracking_data, options = {})
    offer_variant = OfferVariant.cached_find(offer_variant_id)
    tracking_data = tracking_data.with_indifferent_access
    tracking_token = DotOne::Track::Token.new(tracking_data[:token])

    DotOne::AffiliateStats::Recorder.record_clicks(
      offer_variant,
      tracking_token,
      tracking_data,
      options
    )
  end
end
