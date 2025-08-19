require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliate search logs'
    task :affiliate_search_logs, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Affiliate Search Logs'

        puts '  Destroy old data'
        AffiliateSearchLog.delete_all

        puts '  Generate data'

        affiliate_ids = Affiliate.pluck(:id)
        offer_keywords = (0..20).map { |_| Faker::Lorem.word }
        product_keywords = (0..20).map { |_| Faker::Lorem.word }

        (30.days.ago.to_date..Date.today).each do |date|
          AffiliateSearchLog.populate 10 do |log|
            log.date = date
            log.affiliate_id = affiliate_ids.sample
            log.offer_keyword = offer_keywords.sample
            log.offer_keyword_count = rand(1..10)
          end

          AffiliateSearchLog.populate 10 do |log|
            log.date = date
            log.affiliate_id = affiliate_ids.sample
            log.product_keyword = product_keywords.sample
            log.product_keyword_count = rand(1..10)
          end
        end
      end
    end
  end
end
