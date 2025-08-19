require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliate addresses'
    task :affiliate_addresses, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        [AffiliateAddress].each do |klass|
          klass.delete_all
        end

        Affiliate.all.each do |affiliate|
          AffiliateAddress.populate 1 do |address|
            address.address_1 = Faker::Address.street_address
            address.address_2 = Faker::Address.secondary_address
            address.city = Faker::Address.city
            address.state = Faker::Address.state
            address.zip_code = Faker::Address.zip_code
            address.country_id = Country.all.sample
            address.affiliate_id = affiliate.id
          end
        end
      end
    end
  end
end
