require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy advertiser balances'
    task :advertiser_balances, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Advertiser Balances'

        puts '  Destroy Advertiser Balances'
        [AdvertiserBalance].each do |klass|
          klass.delete_all
        end

        puts '  Generate data'
        Network.all.each do |network|
          timestamp = Time.now - rand(1..100).days
          # Create setup fee
          AdvertiserBalance.populate 1 do |ab|
            ab.record_type = AdvertiserBalance::RECORD_TYPE_SETUP_FEE
            ab.debit = 1500
            ab.recorded_at = timestamp
            ab.network_id = network.id
            ab.notes = 'Initial Setup Fee'
          end

          # Create prepay balance
          balance = rand(30_000..59_999)
          AdvertiserBalance.populate 2 do |ab|
            ab.record_type = AdvertiserBalance::RECORD_TYPE_PREPAY
            ab.network_id = network.id
            ab.recorded_at = timestamp + 1.day
            ab.credit = balance
            ab.notes = "Prepay for month #{timestamp.month}"
          end

          # Create advertising fee
          AdvertiserBalance.populate 1 do |ab|
            ab.record_type = AdvertiserBalance::RECORD_TYPE_ADVERTISING_FEE
            ab.network_id = network.id
            ab.recorded_at = timestamp + 4.days
            ab.debit = balance - 10 - rand(balance)
            ab.tax = ab.debit * 0.05
            ab.notes = "Advertising fee for month #{timestamp.month}"
          end
        end
      end
    end
  end
end
