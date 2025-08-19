class Networks::NotifyStatSummaryJob < NotificationJob
  def perform
    Network.active.stat_summary_notification_on.find_each do |network|
      AdvertiserMailer.stat_summary(network).deliver_later
    end
  end
end
