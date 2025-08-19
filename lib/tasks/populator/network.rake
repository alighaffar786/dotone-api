require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy networks'
    task :networks, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Advertisers'

        puts '  Destroy old data'
        [Network].each do |klass|
          klass.delete_all
        end

        password = "advertiser$#{Date.today.year}$#{Date.today.month}"
        crypted_password = DotOne::Utils::Encryptor.encrypt(password)
        language = Language.default

        email_index = 0

        puts '  Generate data'
        Network.populate 10 do |network|
          network.username = Faker::Internet.user_name
          network.crypted_password = crypted_password
          network.name = [Faker::Company.name, Faker::Company.suffix].join(' ')
          network.contact_name = Faker::Name.name
          network.contact_email = "advertiser#{email_index += 1}@converly.com"
          network.contact_phone = Faker::PhoneNumber.phone_number
          network.status = Network.status_active
          network.unique_token = DotOne::Utils.generate_token
          network.time_zone_id = TimeZone.all.sample
          network.country_id = Country.all.sample
          network.currency_id = 1
          network.language_id = language.id
        end
      end
    end
  end
end
