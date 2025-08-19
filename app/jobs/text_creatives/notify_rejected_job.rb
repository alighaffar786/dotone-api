# frozen_string_literal: true

class TextCreatives::NotifyRejectedJob < NotificationJob
  def perform(text_creative_id)
    @text_creative = TextCreative.find_by(id: text_creative_id, status: TextCreative.status_rejected)
    return unless @text_creative

    @network = @text_creative.cached_offer.cached_network

    AdvertiserMailer.text_creative_rejected(@network, @text_creative, cc: true).deliver_later
  end
end
