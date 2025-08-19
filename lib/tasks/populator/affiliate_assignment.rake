require 'faker'
require 'populator'
require 'open-uri'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :affiliate_assignments, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Affiliate Assignments'

        puts '  Destroy old data'
        [AffiliateAssignment].each do |klass|
          klass.delete_all
        end

        affiliate_director = AffiliateUser.affiliate_director.last
        affiliate_manager = AffiliateUser.affiliate_manager.last
        sales_director = AffiliateUser.sales_director.last
        sales_manager = AffiliateUser.sales_manager.last

        puts '  Generate data for affiliate managements'
        # Assign manager to affiliates
        Affiliate.all.each do |affiliate|
          affiliate.affiliate_users << affiliate_director
          affiliate.affiliate_users << affiliate_manager
        end

        puts '  Generate data for advertiser managements'
        # Assign manager to advertisers
        Network.all.each do |network|
          network.affiliate_users << sales_director
          network.affiliate_users << sales_manager
        end
      end
    end
  end
end
