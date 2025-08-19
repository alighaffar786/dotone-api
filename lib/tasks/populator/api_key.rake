require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy api keys'
    task :api_keys, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate API Keys'

        puts '  Destroy old data'
        [ApiKey].each do |klass|
          klass.delete_all
        end

        [Affiliate, Network, PartnerApp].each do |klass|
          records = klass.all
          total_length = records.length
          ids = records.map(&:id)

          puts "  Generate api key data for #{klass}"
          ApiKey.populate total_length do |api_key|
            api_key.owner_id = ids.rotate!.first
            api_key.owner_type = klass.to_s
            api_key.status = ApiKey.status_active
            api_key.value = DotOne::Utils.generate_token
            api_key.secret_key = SecureRandom.urlsafe_base64
            api_key.type = nil
          end
        end

        [Affiliate].each do |klass|
          records = klass.all
          total_length = records.length
          ids = records.map(&:id)

          partner_app_ids = PartnerApp.all.map(&:id)

          puts "  Generate access token data for #{klass}"
          ApiKey.populate total_length do |api_key|
            api_key.owner_id = ids.rotate!.first
            api_key.owner_type = klass.to_s
            api_key.status = ApiKey.status_active
            api_key.value = DotOne::Utils.generate_token
            api_key.secret_key = SecureRandom.urlsafe_base64
            api_key.type = 'AccessToken'
            api_key.partner_app_id = partner_app_ids.rotate!.first
          end
        end
      end
    end
  end
end
