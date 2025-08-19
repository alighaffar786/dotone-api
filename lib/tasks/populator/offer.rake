require 'populator'
require 'faker'
require 'rake_wl'
require 'fileutils'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy offers'
    task :offers, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        raise 'No Network is Present' unless Network.all.present?

        puts 'Generate Offers'

        puts '  Destroy old data'
        [
          Offer, OfferVariant, OfferCategory,
          OfferCountry,
          AffiliateOffer,
          ConversionStep,
          StepPrice
        ].each do |klass|
          klass.delete_all
        end

        Image.where(image_type: ['Brand Image', 'Brand Image Small', 'Brand Image Medium',
          'Brand Image Large']).delete_all

        puts '  Clean up search index'
        begin
          Offer.searchkick_index.delete
        rescue StandardError
        end

        offer_types = ['CPL', 'CPS', 'CPA']

        def populate_conversion_steps(offer, offer_type)
          if offer_type == 'CPL'
            ConversionStep.populate 1 do |cs|
              cs.offer_id = offer.id
              cs.name = 'default'
              cs.label = 'Default'
              cs.true_conv_type = 'CPL'
              cs.affiliate_conv_type = 'CPL'
              cs.true_pay = rand(1..125)
              cs.affiliate_pay = rand(cs.true_pay)
              cs.true_currency_id = Currency.first
              cs.currency_multiplier = 1.0
              cs.days_to_return = 90
              cs.days_to_expire = 90
              cs.on_past_due = 'Do Nothing'
              cs.conversion_mode = 'Auto'
            end
          elsif offer_type == 'CPS'
            ConversionStep.populate 1 do |cs|
              cs.offer_id = offer.id
              cs.name = 'sale'
              cs.label = 'Sale'
              cs.true_conv_type = 'CPS'
              cs.affiliate_conv_type = 'CPS'
              cs.true_share = rand(1..40)
              cs.affiliate_share = rand(cs.true_share)
              cs.true_currency_id = Currency.first
              cs.currency_multiplier = 1.0
              cs.days_to_return = 90
              cs.days_to_expire = 90
              cs.on_past_due = 'Do Nothing'
              cs.conversion_mode = 'Auto'
            end
          elsif offer_type == 'CPA'
            ConversionStep.populate 1 do |cs|
              cs.offer_id = offer.id
              cs.name = 'default'
              cs.label = 'Default'
              cs.true_conv_type = 'CPL'
              cs.affiliate_conv_type = 'CPL'
              cs.true_pay = rand(1..125)
              cs.affiliate_pay = rand(cs.true_pay)
              cs.true_currency_id = Currency.first
              cs.currency_multiplier = 1.0
              cs.days_to_return = 90
              cs.days_to_expire = 90
              cs.on_past_due = 'Do Nothing'
              cs.conversion_mode = 'Auto'
            end
            ConversionStep.populate 1 do |cs|
              cs.offer_id = offer.id
              cs.name = 'sale'
              cs.label = 'Sale'
              cs.true_conv_type = 'CPS'
              cs.affiliate_conv_type = 'CPS'
              cs.true_share = rand(1..40)
              cs.affiliate_share = rand(cs.true_share)
              cs.true_currency_id = Currency.first
              cs.currency_multiplier = 1.0
              cs.days_to_return = 90
              cs.days_to_expire = 90
              cs.on_past_due = 'Do Nothing'
              cs.conversion_mode = 'Auto'
            end
          end
        end

        puts '  Prepare brand images'

        brand_images = {
          '88x31': [],
          '120x60': [],
          '300x125': [],
          '300x300': [],
        }.with_indifferent_access

        1.upto(100) do |idx|
          [[88, 31], [120, 60], [300, 125], [300, 300]].each do |dimension|
            url = "https://cdn.affiliates.one/populators/offers/brand_images/brand-image-#{idx}-#{dimension.first}x#{dimension.last}.jpeg"
            brand_images["#{dimension.first}x#{dimension.last}"] << url
          end
        end

        puts '  Generate data'
        Offer.populate 100 do |offer|
          domain_url = "https://#{Faker::Internet.domain_name}"
          offer.name = "#{Faker::Commerce.product_name} #{rand(1..1000)}"
          offer.network_id = Network.all.sample
          offer.type = 'NetworkOffer'
          offer.need_approval = [0, 1].sample
          offer.approval_message = Faker::Lorem.words(number: 10).join(' ') if offer.need_approval = 1
          offer.tracking_type = 'Real Time'
          offer.conversion_approval_mode = 'Auto'
          offer.created_at = 5.months.ago..1.day.ago
          offer.no_expiration = true
          offer.private_notes = Faker::Lorem.words(number: 5).join(' ')
          offer.published_date = Time.now - rand(7).days
          offer.earning_meter = rand(1..5)
          offer.destination_url = domain_url
          offer.conversion_point = Offer.conversion_point_single
          offer.manager_insight = Faker::Lorem.words(number: 50).join(' ')
          offer.target_audience = Faker::Lorem.words(number: 10).join(' ')
          offer.brand_background = Faker::Lorem.words(number: 50).join(' ')
          offer.product_description = Faker::Lorem.words(number: 50).join(' ')
          offer.suggested_media = Faker::Lorem.words(number: 20).join(' ')
          offer.other_info = Faker::Lorem.words(number: 50).join(' ')

          offer_type = offer_types.sample
          populate_conversion_steps(offer, offer_type)

          # generate default offer variant
          OfferVariant.populate 1 do |variant|
            variant.offer_id = offer.id
            variant.name = 'Default'
            variant.language_id = Currency.all.sample
            variant.description = Faker::Lorem.words(number: 10).join(' ')
            variant.destination_url = [domain_url, Faker::Lorem.characters(number: 10)].join('/')
            variant.status = [OfferVariant.status_active_public, OfferVariant.status_active_private].sample
            variant.created_at = offer.created_at
            variant.is_default = 1
          end # OfferVariant

          # generate non-default offer variant
          OfferVariant.populate 1 do |variant|
            variant.offer_id = offer.id
            variant.name = ['Sale', 'Registration'].sample
            variant.language_id = Currency.all.sample
            variant.description = Faker::Lorem.words(number: 10).join(' ')
            variant.destination_url = [domain_url, Faker::Lorem.characters(number: 10)].join('/')
            variant.status = [OfferVariant.status_active_public, OfferVariant.status_active_private].sample
            variant.created_at = offer.created_at
            variant.is_default = 0
          end # OfferVariant

          records = []
          OfferCategory.populate 4 do |category|
            records << Category.all.sample
            category.offer_id = offer.id
            category.category_id = records.last
          end
          offer.category_names = begin
            records.map(&:name).join(',')
          rescue StandardError
          end
          offer.cache_category_ids = begin
            records.map(&:id).join(',')
          rescue StandardError
          end

          records = []
          OfferCountry.populate 1 do |country|
            records << Country.all.sample
            country.offer_id = offer.id
            country.country_id = records.last
          end
          offer.country_names = records.map(&:name).join(',')
          offer.cache_country_ids = records.map(&:id).join(',')

          offer.track_device = [['Desktop'], ['Mobile Web'], ['Desktop', 'Mobile Web']].sample.to_yaml
        end # Offer

        Offer.all.each do |offer|
          temp_affiliates = []
          AffiliateOffer.populate(rand(1..4)) do |aff_offer|
            # pick affiliate & make sure it does not get picked again
            # for the same offer.
            affiliate = Affiliate.all.reject { |x| temp_affiliates.include?(x) }.sample
            temp_affiliates << affiliate

            aff_offer.affiliate_id = affiliate
            aff_offer.offer_id = offer.id
            aff_offer.approval_status = AffiliateOffer.approval_statuses.sample
            aff_offer.agree_to_terms = 1
            aff_offer.created_at = Time.now - rand(30).day

            offer.ordered_conversion_steps.each do |conversion_step|
              if conversion_step.true_conv_type == 'CPL'
                custom_amount = conversion_step.affiliate_pay + rand(conversion_step.true_pay - conversion_step.affiliate_pay)
                StepPrice.populate 1 do |sp|
                  sp.affiliate_offer_id = aff_offer.id
                  sp.conversion_step_id = conversion_step.id
                  sp.custom_amount = custom_amount
                end
              elsif conversion_step.true_conv_type == 'CPS'
                custom_amount = conversion_step.affiliate_share + rand(conversion_step.true_share - conversion_step.affiliate_share)
                StepPrice.populate 1 do |sp|
                  sp.affiliate_offer_id = aff_offer.id
                  sp.conversion_step_id = conversion_step.id
                  sp.custom_share = custom_amount
                end
              end
            end
          end # AffiliateOffer
        end

        Offer.all.each do |offer|
          puts "  Assign additional data to offer #{offer.id}:"
          # Assign offer_name flag
          puts '    Assign flag offer name'
          offer.flag('offer_name', "#{Faker::Commerce.product_name} #{rand(1..1000)}")

          # Assign brand images
          puts '    Assign brand images'

          image = Image.new(owner_type: 'Offer', owner_id: offer.id, image_type: 'Brand Image')
          image.cdn_url = brand_images['300x300'].rotate!.first
          image.save
          offer.brand_image = image

          image = Image.new(owner_type: 'Offer', owner_id: offer.id, image_type: 'Brand Image Small')
          image.cdn_url = brand_images['88x31'].rotate!.first
          image.save
          offer.brand_image_small = image

          image = Image.new(owner_type: 'Offer', owner_id: offer.id, image_type: 'Brand Image Medium')
          image.cdn_url = brand_images['120x60'].rotate!.first
          image.save
          offer.brand_image_medium = image

          image = Image.new(owner_type: 'Offer', owner_id: offer.id, image_type: 'Brand Image Large')
          image.cdn_url = brand_images['300x125'].rotate!.first
          image.save
          offer.brand_image_large = image

          offer.save

          puts '    Index to search'

          retry_count = 0
          begin
            offer.reindex
          rescue Exception => e
            if retry_count < 5
              retry_count += 1
              puts "    Retrying in 5 seconds (Retry Count: #{retry_count})"
              sleep 5
              retry
            end
          end
        end
      end
    end
  end
end
