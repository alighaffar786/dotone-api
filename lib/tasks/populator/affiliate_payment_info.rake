require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliate payment infos'
    task :affiliate_payment_infos, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Affiliate Payment Infos'

        puts '  Destroy old data'
        [AffiliatePaymentInfo].each do |klass|
          klass.delete_all
        end

        puts '  Generate data'
        Affiliate.all.each do |affiliate|
          AffiliatePaymentInfo.populate 1 do |info|
            info.payment_type = 'Wire Transfer'
            info.affiliate_id = affiliate.id
            info.affiliate_address_id = affiliate.affiliate_address.id
            info.payee_name = affiliate.full_name
            info.bank_name = Faker::Company.name
            info.bank_identification = Faker::Number.number(digits: 8)
            info.branch_name = Faker::Company.name
            info.branch_identification = Faker::Number.number(digits: 8)
            info.iban = Faker::Number.number(digits: 11)
            info.routing_number = Faker::Number.number(digits: 8)
            info.account_number = Faker::Number.number(digits: 10)
            info.status = AffiliatePaymentInfo.status_confirmed
            info.preferred_currency = 'TWD'
          end
        end
      end
    end
  end
end
