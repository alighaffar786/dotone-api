class AffiliateMailerPreview < ActionMailer::Preview
  def event_campaign_completed
    campaign = AffiliateOffer.completed.first
    AffiliateMailer.event_campaign_completed(campaign)
  end

  def event_campaign_changes_required
    campaign = AffiliateOffer.changes_required.first
    AffiliateMailer.event_campaign_changes_required(campaign)
  end

  def event_campaign_rejected
    campaign = AffiliateOffer.joins(:offer).where(offers: { type: 'EventOffer' }).suspended.first
    AffiliateMailer.event_campaign_rejected(campaign)
  end

  def xhour_offer_paused_24
    offer = NetworkOffer.active.first
    affiliate = AffiliateOffer.where(offer_id: offer.id).last.affiliate
    hour = 24
    AffiliateMailer.xhour_offer_paused(offer, affiliate, hour, cc: true)
  end
end
