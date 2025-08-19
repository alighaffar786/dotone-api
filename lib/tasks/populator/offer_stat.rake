require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy offer stats'
    task :offer_stats, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Postbacks'

        puts '  Destroy old data'
        [OfferStat].each do |klass|
          klass.delete_all
        end

        puts '  Generate data'
        Offer.all.each do |offer|
          ((Date.today - 40.days)..Date.today).each do |date|
            OfferStat.populate 1 do |offer_stat|
              offer_stat.offer_id = offer.id
              offer_stat.date = date
              offer_stat.detail_view_count = rand(1..1000)
            end
          end
        end
      end
    end
  end
end
