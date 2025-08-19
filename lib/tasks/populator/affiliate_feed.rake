require 'faker'
require 'populator'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :affiliate_feeds, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Feeds'

        puts '  Destroy feeds'
        AffiliateFeed.delete_all

        puts '  Generate data'
        AffiliateFeed.populate 100 do |feed|
          feed.content = Faker::Lorem.paragraph
          feed.published_at = 1.week.ago..Time.now
          feed.status = AffiliateFeed.status_published
          feed.created_at = feed.published_at
          feed.title = Faker::Lorem.words(number: 5).join(' ')
          feed.sticky = false
          feed.role = AffiliateFeed.roles.sample
          feed.feed_type = AffiliateFeed.feed_types.sample
        end
      end
    end
  end
end
