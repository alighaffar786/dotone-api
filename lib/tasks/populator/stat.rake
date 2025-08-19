require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    namespace :stats do
      desc "Populate Redshift's stats with affiliate stat's data"
      task :copy_affiliate_stats, [:options] => :environment do |_t, args|
        RakeWl.when_populator_can_run do
          options = args[:options] || {}

          puts 'Generate Stats'

          puts '  Destroy old data'
          [Stat].each do |klass|
            klass.delete_all
          end

          # Import to Redshift's Stat
          puts '  Copy transaction data from MySQL to Redshift'

          records = []

          AffiliateStat.all.each do |affiliate_stat|
            records << affiliate_stat.attributes
          end

          # Make sure forex is stored as JSON in Redshift
          records = records.map do |record|
            record['forex'] = record['forex'] ? JSON.generate(record['forex']) : nil
            record
          end

          Stat.insert_all!(records)
        end
      end

      desc 'Populate impressions data'
      task :impressions, [:options] => :environment do |_t, args|
        RakeWl.when_populator_can_run do
          options = args[:options] || {}

          affiliate_offers = AffiliateOffer.all
          image_creatives = ImageCreative.all

          puts 'Generate impressions'
          impression_data = []

          1.upto(50_000) do
            affiliate_offer = affiliate_offers.sample
            offer_variant_id = affiliate_offer.cached_offer_variant.id
            network_id = affiliate_offer.cached_offer.network_id
            offer_id = affiliate_offer.cached_offer.id

            impression_data << {
              impression: 1,
              id: DotOne::Utils.generate_token,
              network_id: network_id,
              offer_id: offer_id,
              offer_variant_id: offer_variant_id,
              affiliate_id: affiliate_offer.affiliate_id,
              http_user_agent: Faker::Internet.user_agent,
              http_referer: Faker::Internet.url,
              ip_address: Faker::Internet.ip_v4_address,
              recorded_at: Time.now - rand(86_400).minutes,
              affiliate_offer_id: affiliate_offer.id,
              image_creative_id: image_creatives.sample.id,
            }
          end

          # Import Impression Stats
          puts '  Import impression stats'
          to_import = []

          impression_data.each do |data|
            to_import << data
          end

          Stat.insert_all!(to_import)
        end
      end
    end
  end
end
