require 'populator'
require 'faker'
require 'rake_wl'

module WlPopHelper
  def self.skip_populating_ad_slot?(options)
    options.present? && options[:skip].present? && options[:skip].include?('ad_slots')
  end

  def self.pop_routine(options)
    # Create AffiliateUser and its related contents
    Rake::Task['wl:pop:affiliate_users'].invoke(options)

    # Create Affiliate and its related contents
    Rake::Task['wl:pop:affiliates'].invoke(options)
    Rake::Task['wl:pop:affiliate_payment_infos'].invoke(options)

    # Create Network (Advertiser) and its related contents
    Rake::Task['wl:pop:networks'].invoke(options)

    # Create Advertiser Balances
    Rake::Task['wl:pop:advertiser_balances'].invoke(options)

    # Create Manager Assignments
    Rake::Task['wl:pop:affiliate_assignments'].invoke(options)

    # Create Offer and its related contents
    Rake::Task['wl:pop:offers'].invoke(options)
    Rake::Task['wl:pop:offer_stats'].invoke(options)

    # Create Owner Has Tags
    Rake::Task['wl:pop:owner_has_tags'].invoke(options)

    # Create Ad Slots
    Rake::Task['wl:pop:ad_slots'].invoke(options) unless WlPopHelper.skip_populating_ad_slot?(options)

    # Create Creatives
    Rake::Task['wl:pop:creatives'].invoke(options)

    # Create Transaction, Stats
    Rake::Task['wl:pop:affiliate_stats'].invoke(options)
    Rake::Task['wl:pop:stats:copy_affiliate_stats'].invoke(options)
    Rake::Task['wl:pop:postbacks'].invoke(options)
    Rake::Task['wl:pop:stats:impressions'].invoke(options)
    Rake::Task['wl:pop:image_creative_stats'].invoke(options)

    # Create Product
    Rake::Task['wl:pop:products'].invoke(options)

    # Create API Keys
    Rake::Task['wl:pop:api_keys'].invoke(options)

    # Create Affiliate Feed Data
    Rake::Task['wl:pop:affiliate_feeds'].invoke(options)

    # Create Contact Lists
    Rake::Task['wl:pop:contact_lists'].invoke(options)

    # Create Downloads
    Rake::Task['wl:pop:downloads'].invoke(options)

    # Create Uploads
    Rake::Task['wl:pop:uploads'].invoke(options)
  end
end

namespace :wl do
  namespace :pop do
    desc 'Populate certain Wl Company (Need to be in Development or Staging Environment)'
    task for_network: :environment do
      RakeWl.when_populator_can_run do
        # To make sure all models are loaded.
        # This is to resolve some models missing when running rake tasks
        # to populate staging environment
        Rails.application.eager_load!

        options = {
          data_size: 10_000,
          force: true,
          start_at: '2000-01-01',
          end_at: '2020-01-01',
          offer_ids: 'ALL',
          min_id: '0',
        }

        WlPopHelper.pop_routine(options)
      end
    end
  end
end
