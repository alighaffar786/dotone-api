class AdvertiserMailerPreview < ActionMailer::Preview
  def stat_summary
    network = Network.active.first
    AdvertiserMailer.stat_summary(network)
  end

  def status_active
    network = Network.active.first
    AdvertiserMailer.status_active(network)
  end
end
