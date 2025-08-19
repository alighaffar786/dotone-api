require 'populator'
require 'faker'
require 'rake_wl'
# require "useragents"

module WlPopStatHelper
  def retrieve_affiliate_offer(step_price)
    to_return = step_price.cached_affiliate_offer rescue nil
    to_return = AffiliateOffer.all.sample if to_return.blank?
    to_return
  end

  def retrieve_conversion_step(step_price, offer)
    to_return = step_price.cached_conversion_step rescue nil
    to_return = offer.cached_default_conversion_step if to_return.blank?
    to_return
  end

  def retrieve_affiliate_pay(step_price, conversion_step)
    to_return = step_price.custom_amount rescue nil
    to_return = conversion_step.affiliate_pay if to_return.blank?
    to_return
  end

  def retrieve_affiliate_share(step_price, conversion_step)
    to_return = step_price.custom_share rescue nil
    to_return = conversion_step.affiliate_share if to_return.blank?
    to_return
  end
end

namespace :wl do
  namespace :pop do
    desc 'Populate database with stats for offers'
    task :affiliate_stats, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        require "#{Rails.root}/app/lib/vibrant_back/utility.rb"
        include WlPopStatHelper

        options = args[:options] || {}

        sample_data_count = RakeWl.ask_data_size(options)

        puts 'Generate Transactions'

        puts '  Destroy old data'
        [
          AffiliateStat, AffiliateStatCapturedAt, AffiliateStatPublishedAt,
          AffiliateStatConvertedAt,
          Order
        ].each do |klass|
          klass.delete_all
        end

        puts "== Generating #{sample_data_count} sample data =="

        subid1 = [
          'facebook', 'google', 'bing', 'yahoo', 'mobile', 'pubnetwork', 'aol', 'cnn', 'msnbc', 'nytimes', 'weatherchannel',
          'twitter', 'bookclub', 'blogger', 'adtop', 'pinterest', 'coolads', 'supads', 'ezanga', '7search', 'craigslist',
          'scribd', 'latimes', 'chicagotribune', 'blogads', nil
        ]
        subid2 = ['search', 'intext', 'display', 'banner', nil]
        subid3 = ['top', 'bottom', 'vertical', 'square', 'horizontal', nil]
        subid4 = ['top', 'bottom', 'vertical', 'square', 'horizontal', nil] # TODO: change to something else
        subid5 = ['top', 'bottom', 'vertical', 'square', 'horizontal', nil]
        gaid = ['gaid a', 'gaid b', 'gaid c', 'gaid d', nil]

        current_rates = DotOne::Utils::CurrencyConverter.generate_rate_map(Currency.default_code)
        current_currency = Currency.current_code
        step_prices = StepPrice.all
        ads = Ad.all
        ad_slots_ids = [nil, AdSlot.all.map(&:id)].flatten
        language_id = Language.default.id

        puts '  Generate data on AffiliateStat'

        AffiliateStat.populate sample_data_count do |stat|
          # stat.id = DotOne::Utils.generate_token

          # Determine some random data
          step_price = step_prices.sample
          affiliate_offer = retrieve_affiliate_offer(step_price)
          network = affiliate_offer.cached_offer_variant.cached_offer.cached_network
          offer = affiliate_offer.cached_offer_variant.cached_offer
          offer_variant = affiliate_offer.cached_offer_variant
          affiliate = affiliate_offer.cached_affiliate
          conversion_step = retrieve_conversion_step(step_price, offer)
          is_captured = [true, false].sample

          # Populate
          conversion = [nil, 1].sample
          ad_slot_id = ad_slots_ids.sample

          # populate
          stat.network_id = network.id
          stat.offer_id = offer.id
          stat.offer_variant_id = offer_variant.id
          stat.affiliate_id = affiliate.id
          stat.affiliate_offer_id = affiliate_offer.id
          stat.image_creative_id = offer_variant.cached_image_creatives.sample
          stat.subid_1 = subid1.sample
          stat.subid_2 = subid2.sample
          stat.subid_3 = subid3.sample
          stat.subid_4 = subid4.sample
          stat.subid_5 = subid5.sample
          stat.gaid = gaid.sample
          stat.http_user_agent = UserAgents.rand
          stat.http_referer = Faker::Internet.url
          stat.ip_address = Faker::Internet.ip_v4_address
          stat.isp = ['ATT', 'Comcast', 'Verizon', nil].sample
          stat.browser = ['Mozilla', 'IE', 'Chrome', nil].sample
          stat.browser_version = ['8.0', '9.0', '10.0', nil].sample
          stat.device_type = ['Mobile', 'Desktop', nil].sample
          stat.device_brand = ['Samsung', 'Apple', 'Microsoft', 'Nokia', nil].sample
          stat.device_model = ['Note', 'Iphone 6', 'Lumnia', nil].sample
          stat.ip_country = 'United States'
          stat.true_conv_type = conversion_step.true_conv_type
          stat.affiliate_conv_type = conversion_step.affiliate_conv_type
          stat.recorded_at = (Time.now - rand(10).days - rand(23).hours - rand(60).minutes - rand(60).seconds)
          stat.clicks = 1
          stat.ad_slot_id = ad_slot_id
          stat.language_id = language_id

          if conversion
            stat.approval = [AffiliateStat.approval_approved, AffiliateStat.approval_rejected].sample
            stat.captured_at = stat.recorded_at + rand(10).days + rand(23).hours + rand(60).minutes
          end

          if conversion && conversion_step.true_conv_type == 'CPL'
            # create CPL stat
            stat.approval = AffiliateStat.approval_pending
            stat.captured_at = stat.recorded_at + rand(10).days + rand(23).hours + rand(60).minutes
            stat.conversions = 1
            stat.true_pay = conversion_step.true_pay
            stat.affiliate_pay = retrieve_affiliate_pay(step_price, conversion_step)
            stat.forex = current_rates.to_json
            stat.original_currency = current_currency

            is_converted = [true, false].sample

            if is_converted
              stat.published_at = stat.captured_at + rand(60).minutes
              stat.converted_at = stat.published_at
              stat.approval = [AffiliateStat.approval_approved, AffiliateStat.approval_rejected].sample
            end

          elsif is_captured && conversion_step.true_conv_type == 'CPS'
            # create CPS Order
            is_converted = [true, false].sample

            Order.populate 1 do |order|
              order.recorded_at = stat.recorded_at + rand(10).days + rand(23).hours + rand(60).minutes
              order.offer_id = stat.offer_id
              order.offer_variant_id = stat.offer_variant_id
              order.affiliate_id = stat.affiliate_id
              order.order_number = "TEST-#{stat.network_id}-#{stat.id}"
              order.total = rand(100..10_099)
              order.affiliate_share = retrieve_affiliate_share(step_price, conversion_step)
              order.affiliate_pay = (order.total * order.affiliate_share) / 100 rescue conversion_step.affiliate_pay
              order.true_share = conversion_step.true_share
              order.true_pay = (order.total * conversion_step.true_share) / 100 rescue conversion_step.true_pay
              order.status = Order.status_pending

              if is_converted
                order.status = [Order.status_confirmed, Order.status_rejected].sample
                order.published_at = order.recorded_at + rand(10).days + rand(23).hours + rand(60).minutes
                order.converted_at = order.published_at
              end

              order.affiliate_stat_id = stat.id
              order.step_name = conversion_step.name
              order.step_label = conversion_step.label
              order.affiliate_conv_type = stat.affiliate_conv_type
              order.true_conv_type = stat.true_conv_type
              order.network_id = stat.network_id
              order.forex = current_rates.to_json
              order.original_currency = current_currency

              # create copy stat
              AffiliateStat.populate 1 do |copy_stat|
                copy_stat.order_id = order.id
                copy_stat.published_at = order.published_at
                copy_stat.converted_at = order.converted_at
                copy_stat.conversions = 1
                copy_stat.network_id = order.network_id
                copy_stat.offer_id = order.offer_id
                copy_stat.offer_variant_id = order.offer_variant_id
                copy_stat.affiliate_id = order.affiliate_id
                copy_stat.true_pay = order.true_pay
                copy_stat.affiliate_pay = order.affiliate_pay
                copy_stat.recorded_at = stat.recorded_at
                copy_stat.step_name = order.step_name
                copy_stat.step_label = order.step_label
                copy_stat.true_conv_type = order.true_conv_type
                copy_stat.affiliate_conv_type = order.affiliate_conv_type
                copy_stat.captured_at = order.recorded_at
                copy_stat.approval = if order.confirmed?
                  AffiliateStat.approval_approved
                elsif order.rejected?
                  AffiliateStat.approval_rejected
                elsif order.pending?
                  AffiliateStat.approval_pending
                end
                copy_stat.order_number = order.order_number
                copy_stat.forex = current_rates.to_json
                copy_stat.original_currency = current_currency
                copy_stat.language_id = language_id
              end
            end
          end
        end

        # Import to AffiliateStatCapturedAt
        puts '  Generate data on AffiliateStatCapturedAt'
        sql = <<-SQL
          INSERT INTO affiliate_stat_captured_ats
          SELECT *
          FROM affiliate_stats
          WHERE captured_at IS NOT NULL
        SQL
        AffiliateStatCapturedAt.connection.execute(sql)

        # Import to AffiliateStatPublishedAt
        puts '  Generate data on AffiliateStatPublishedAt'
        sql = <<-SQL
          INSERT INTO affiliate_stat_published_ats
          SELECT *
          FROM affiliate_stats
          WHERE published_at IS NOT NULL
        SQL
        AffiliateStatPublishedAt.connection.execute(sql)

        # Import to AffiliateStatConvertedAt
        puts '  Generate data on AffiliateStatConvertedAt'
        sql = <<-SQL
          INSERT INTO affiliate_stat_converted_ats
          SELECT *
          FROM affiliate_stats
          WHERE converted_at IS NOT NULL
        SQL
        AffiliateStatConvertedAt.connection.execute(sql)
      end
    end # End of affiliate_stats task
  end
end
