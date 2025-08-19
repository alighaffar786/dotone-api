require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy event offers'
    task :event_offers, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        raise 'No Network is Present' unless Network.all.present?

        puts 'Generate Event Offers'

        puts '  Destroy old data'
        [OfferTerm, EventInfo].each do |klass|
          klass.delete_all
        end

        OwnerHasTag.where(owner_type: 'EventInfo').delete_all
        Image.where(owner_type: 'EventInfo').delete_all
        Image.where(owner_type: 'Offer', image_type: 'Brand Image', owner_id: EventOffer.select(:id)).delete_all
        AffHash.where(entity_type: 'Offer', entity_id: EventOffer.select(:id)).delete_all
        AffHash.where(entity_type: 'AffiliateOffer', entity_id: AffiliateOffer.where(offer_id: EventOffer.select(:id)).select(:id)).delete_all
        [OfferVariant, OfferCategory, OfferCountry, OfferTerm, AffiliateOffer, ConversionStep].each do |klass|
          klass.where(offer_id: EventOffer.select(:id)).delete_all
        end
        [EventHasCategoryGroup, EventInfo, EventOffer].each do |klass|
          klass.delete_all
        end

        puts '  Prepare images'

        image_path = "#{Rails.root}/lib/tasks/populator/assets/offers/brand_images"

        FileUtils.mkdir_p(image_path)

        item_images = []

        1.upto(100) do |idx|
          [[300, 300]].each do |dimension|
            file_name = "#{image_path}/brand-image-#{idx}-#{dimension.first}x#{dimension.last}.jpeg"
            item_images << file_name
          end
        end

        def populate_conversion_steps(event_offer)
          ConversionStep.populate 1 do |cs|
            cs.offer_id = event_offer.id
            cs.name = 'default'
            cs.label = 'Default'
            cs.true_conv_type = 'CPL'
            cs.affiliate_conv_type = 'CPL'
            cs.true_pay = rand(1..125)
            cs.affiliate_pay = rand(cs.true_pay)
            cs.true_currency_id = Currency.first
            cs.currency_multiplier = 1.0
            cs.days_to_return = 90
            cs.days_to_expire = 0
          end
        end

        def populate_media_categories(event_info)
          records = []
          OwnerHasTag.populate 1 do |tag|
            records << AffiliateTag.parent_media_categories.sample
            tag.owner_type = 'EventInfo'
            tag.owner_id = event_info.id
            tag.affiliate_tag_id = records.last
          end

          OwnerHasTag.populate 1 do |tag|
            tag.owner_type = 'EventInfo'
            tag.owner_id = event_info.id
            tag.affiliate_tag_id = AffiliateTag.children_media_categories.where(parent_category_id: records.map(&:id)).sample
          end
        end

        def populate_category_groups(event_info)
          EventHasCategoryGroup.populate 1 do |group|
            group.event_info_id = event_info.id
            group.category_group_id = CategoryGroup.pluck(:id).sample
          end
        end

        def populate_item_images(event_info, item_images)
          item_images.sample(rand(1..6)).each do |path|
            image = Image.new(owner_type: 'EventInfo', owner_id: event_info.id)
            image.asset = File.open(path)
            image.save
          end
        end

        def populate_event_info(event_offer, item_images)
          EventInfo.populate 1 do |info|
            info.offer_id = event_offer.id
            info.related_offer_id = NetworkOffer.pluck(:id).sample
            info.is_private_event = [0, 1].sample
            info.availability_type = EventInfo.availability_types.sample
            info.event_type = EventInfo.event_types.sample
            info.coordinator_email = Faker::Internet.email
            info.applied_by = event_offer.published_date - rand(7).days
            info.selection_by = info.applied_by - rand(7).days
            info.submission_by = info.selection_by - rand(7).days
            info.evaluation_by = info.submission_by - rand(7).days
            info.published_by = info.evaluation_by - rand(7).days
            info.value = rand(125)
            info.fulfillment_type = EventInfo.fulfillment_types.sample
            info.is_supplement_needed = [0, 1].sample
            info.is_address_needed = [0, 1].sample
            info.supplement_notes = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.event_contract = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.details = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.event_requirements = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.instructions = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.keyword_requirements = Faker::Lorem.paragraph(sentence_count: rand(5..10))
            info.quota = rand(10..100)
            info.popularity = rand(1..10)
            info.popularity_unit = EventInfo.popularity_units.sample
            info.is_affiliate_requirement_needed = [0, 1].sample
            populate_media_categories(info)
            populate_category_groups(info)
            populate_item_images(info, item_images)
          end
        end

        def populate_offer_variant(event_offer)
          OfferVariant.populate 1 do |variant|
            variant.offer_id = event_offer.id
            variant.name = 'Default'
            variant.language_id = Currency.all.sample
            variant.status = OfferVariant.event_statuses.sample
            variant.created_at = event_offer.created_at
            variant.is_default = 1
          end
        end

        def populate_categories(event_offer)
          records = []
          OfferCategory.populate 1 do |category|
            records << Category.all.sample
            category.offer_id = event_offer.id
            category.category_id = records.last
          end
          event_offer.category_names = records.map(&:name).join(',') rescue nil
          event_offer.cache_category_ids = records.map(&:id).join(',') rescue nil
        end

        def populate_countries(event_offer)
          records = []
          OfferCountry.populate 1 do |country|
            records << Country.all.sample
            country.offer_id = event_offer.id
            country.country_id = records.last
          end
          event_offer.country_names = records.map(&:name).join(',')
          event_offer.cache_country_ids = records.map(&:id).join(',')
        end

        def populate_terms(event_offer)
          Term.pluck(:id).sample(rand(2..5)).each do |term_id|
            OfferTerm.create(
              term_id: term_id,
              offer_id: event_offer.id,
            )
          end
        end

        def populate_brand_image(event_offer, brand_images)
          image = Image.new(owner_type: 'Offer', owner_id: event_offer.id, image_type: 'Brand Image')
          image.asset = File.open(brand_images.rotate!.first)
          image.save
        end

        def populate_shipping_address(aff_offer, aff_address)
          return unless aff_address

          AffHash.populate 1 do |aff_hash|
            aff_hash.entity_id = aff_offer.id
            aff_hash.entity_type = 'AffiliateOffer'
            aff_hash.flag = { 'shipping_address' => aff_address.address_attributes }
          end
        end

        def populate_affiliate_offer(event_offer)
          n = rand(5..10)
          affiliate_ids = Affiliate.pluck(:id).sample(n)
          AffiliateOffer.populate n do |aff_offer|
            affiliate = Affiliate.find(affiliate_ids.shift)
            aff_offer.affiliate_id = affiliate.id
            aff_offer.offer_id = event_offer.id
            aff_offer.approval_status = AffiliateOffer.event_approval_statuses.sample
            aff_offer.agree_to_terms = 1
            aff_offer.created_at = Time.now - rand(30).day
            aff_offer.event_contract_signed_at = aff_offer.created_at + rand(1..7).days
            aff_offer.event_contract_signature = affiliate.full_name
            aff_offer.event_contract_signed_ip_address = Faker::Internet.ip_v4_address
            aff_offer.event_draft_url = "http://#{Faker::Internet.domain_name}/#{Faker::Internet.domain_suffix}"
            aff_offer.event_published_url = "http://#{Faker::Internet.domain_name}/#{Faker::Internet.domain_suffix}"
            aff_offer.event_draft_notes = Faker::Lorem.paragraph(sentence_count: rand(1..3))
            aff_offer.event_supplement_notes = Faker::Lorem.paragraph(sentence_count: rand(1..3))
            aff_offer.event_shipment_notes = Faker::Lorem.paragraph(sentence_count: rand(1..3))
            aff_offer.event_promotion_notes = Faker::Lorem.paragraph(sentence_count: rand(1..3))
            aff_offer.phone_number = Faker::PhoneNumber.phone_number
            aff_offer.site_info_id = affiliate.site_infos.pluck(:id).sample
            populate_shipping_address(aff_offer, affiliate.affiliate_address)
          end
        end

        puts '  Generate data'
        EventOffer.populate 100 do |event_offer|
          event_offer.name = "#{Faker::Commerce.product_name} #{rand(1..1000)}"
          event_offer.network_id = Network.pluck(:id).sample
          event_offer.type = 'EventOffer'
          event_offer.need_approval = true
          event_offer.approval_message = Faker::Lorem.words(number: 10).join(' ')
          event_offer.tracking_type = 'Real Time'
          event_offer.conversion_approval_mode = 'Auto'
          event_offer.created_at = 5.months.ago..1.day.ago
          event_offer.no_expiration = true
          event_offer.destination_url = "http://#{Faker::Internet.domain_name}"
          event_offer.conversion_point = Offer.conversion_point_single
          event_offer.short_description = Faker::Lorem.words(number: 10).join(' ')
          event_offer.published_date = Time.now - rand(7).days
          event_offer.earning_meter = rand(1..5)

          populate_offer_variant(event_offer)
          populate_conversion_steps(event_offer)
          populate_event_info(event_offer, item_images)
          populate_categories(event_offer)
          populate_countries(event_offer)
          populate_terms(event_offer)
          populate_brand_image(event_offer, item_images)
          populate_affiliate_offer(event_offer)
        end

        puts '    Index to search'
        Offer.all.each do |offer|
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
