require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy offers'
    task :ads, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        [Ad, AdGroup, Campaign, Channel].each do |klass|
          klass.delete_all
        end

        Channel.populate 10 do |channel|
          channel.name = Faker::Company.name
          Campaign.populate 5 do |campaign|
            campaign.channel_id = channel.id
            campaign.name = Faker::Commerce.department
            AdGroup.populate 3 do |ad_group|
              ad_group.campaign_id = campaign.id
              ad_group.name = Faker::Commerce.color
              ad_group.max_cpc = Faker::Commerce.price
              Ad.populate 5 do |ad|
                ad.ad_group_id = ad_group.id
                ad.name = Faker::Commerce.product_name
                ad.destination_url = Faker::Internet.url
                ad.offer_id = Offer.all.sample
              end
            end
          end
        end
      end
    end
  end
end
