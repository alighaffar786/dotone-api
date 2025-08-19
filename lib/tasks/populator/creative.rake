require 'faker'
require 'populator'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :creatives, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Creatives'

        puts '  Destroy old data'

        [Creative, ImageCreative, TextCreative, TextCreativeCategory].each do |klass|
          klass.delete_all
        end

        Image.where(owner_type: 'TextCreative').delete_all

        offer_variants = OfferVariant.all

        # Prepare images from online resources
        puts '  Prepare banner images'
        image_path = "#{RakeWl::CDN_BASE_PATH}/image_creatives"
        banners = {}
        available_banner_sizes = ['468x60', '728x90', '300x250', '160x600', '120x600']
        available_banner_sizes.each do |size|
          banners[size] = "#{image_path}/banner-#{size}.png"
        end

        puts '  Generate data for banner creatives'
        ImageCreative.populate 300 do |image_creative|
          banner_size = available_banner_sizes.rotate!.first
          width, height = banner_size.split('x')
          image_creative.is_infinity_time = true
          image_creative.status = ImageCreative::STATUSES.sample
          image_creative.locale = 'en-US'
          image_creative.internal = 0
          image_creative.width = width
          image_creative.height = height
          image_creative.size = banner_size
          image_creative.cdn_url = banners[banner_size]

          Creative.populate 1 do |creative|
            creative.offer_variant_id = offer_variants.sample.id
            creative.entity_id = image_creative.id
            creative.entity_type = 'ImageCreative'
          end
        end

        puts '  Generate data for native ads'
        offer_variants = OfferVariant.all.to_a
        locales = ['en-US', 'zh-TW']

        TextCreative.populate offer_variants.length * 2 do |text_creative|
          offer_variant = offer_variants.rotate!.first
          offer = offer_variant.offer

          text_creative.creative_name = "Feed Creative #{rand(1..100)}"

          content = []
          1.upto(12) { content << Faker::Lorem.characters(number: 5) }
          text_creative.content = content.join(' ')

          text_creative.title = Faker::Lorem.characters(number: 10)
          text_creative.is_infinity_time = true
          text_creative.status = 'Active'

          content = []
          1.upto(4) { content << Faker::Lorem.characters(number: 5) }
          text_creative.content_1 = content.join(' ')

          content = []
          1.upto(3) { content << Faker::Lorem.characters(number: 5) }
          text_creative.content_2 = content.join(' ')

          text_creative.button_text = 'Shop Now'
          text_creative.deal_scope = TextCreative::DEAL_SCOPES.sample
          text_creative.custom_landing_page = [offer.destination_url, Faker::Lorem.characters(number: 10)].join('/')

          text_creative.published_at = Time.now - 1.week

          text_creative.locale = locales.rotate!.first

          Creative.populate 1 do |creative|
            creative.offer_variant_id = offer_variant.id
            creative.entity_id = text_creative.id
            creative.entity_type = 'TextCreative'
          end

          offer.categories.each do |category|
            TextCreativeCategory.populate 1 do |text_creative_category|
              text_creative_category.category_id = category.id
              text_creative_category.text_creative_id = text_creative.id
            end
          end
        end

        image_path = "#{RakeWl::CDN_BASE_PATH}/text_creatives"

        TextCreative.all.each do |text_creative|
          # Assign flag data
          text_creative.original_price = rand(100..1099)
          text_creative.discount_price = (text_creative.original_price.to_f - 1) + rand(100)
          text_creative.offer_name = Faker::Lorem.characters(number: 10)

          # Assign image
          image = Image.new(
            owner_type: 'TextCreative',
            owner_id: text_creative.id,
            cdn_url: "#{image_path}/image-300x300-#{rand(1..50)}.jpg",
          )
          text_creative.image = image

          text_creative.save
        end
      end
    end
  end
end
