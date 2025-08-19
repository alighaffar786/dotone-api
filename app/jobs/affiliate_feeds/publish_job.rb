class AffiliateFeeds::PublishJob < MaintenanceJob
  def perform
    published_announcements
    republished_announcements
  end

  def published_announcements
    AffiliateFeed.scheduled.between(nil, Date.today, :published_at, any: true).find_each do |feed|
      catch_exception do
        feed.update!(status: AffiliateFeed.status_published)
      end
    end
  end

  def republished_announcements
    AffiliateFeed.published.between(nil, Date.today, :republished_at, any: true).where('republished_at > published_at').find_each do |feed|
      catch_exception do
        feed.update!(published_at: feed.republished_at)
      end
    end
  end
end
