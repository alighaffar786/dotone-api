require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy partner apps'
    task :partner_apps, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Partner Apps'

        puts '  Destroy old data'
        [PartnerApp].each do |klass|
          klass.delete_all
        end

        email_index = 0

        puts '  Generate data'

        PartnerApp.populate 5 do |p|
          p.name = Faker::Company.name
          p.company_name = [Faker::Company.name, Faker::Company.suffix].join(' ')
          p.email_address = "partner_app#{email_index += 1}@converly.com"
          p.app_url = "http://#{Faker::Internet.domain_name}"
          p.visibility = 'Public'
        end
      end
    end
  end
end
