require 'populator'
require 'faker'
require 'rake_wl'
require 'digest/sha1'

namespace :wl do
  namespace :pop do
    desc 'Populate database with fake product data'
    task :products, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Products'

        # Full cleanup
        puts '  Destroy old data'
        [Product].each do |klass|
          klass.delete_all
        end

        brands = []
        1.upto(20) do
          brands << Faker::Company.name
        end

        offers = NetworkOffer.all

        puts '  Generate data'

        Product.populate 10_000 do |product|
          product.client_id_value = rand(1..100_000_000)
          product.title = Faker::Commerce.product_name
          product.description_1 = Faker::Lorem.sentences(number: 3).join(' ')
          product.description_2 = Faker::Lorem.sentences(number: 6).join(' ')
          product.brand = brands.sample
          product.category_1 = Faker::Commerce.department
          product.product_url = Faker::Internet.url
          product.locale = 'EN-US'
          product.currency = 'USD'
          product.offer_id = offers.sample.id

          keys = [
            product.client_id_value,
            product.offer_id,
            product.locale,
            product.currency,
          ]
          product.uniq_key = Digest::SHA1.hexdigest(keys.compact.join(' - '))

          usd_price = Faker::Commerce.price

          product.prices = { retail: { TWD: usd_price * 30, CNY: usd_price * 6.5, USD: usd_price }, sale: {}, discount: {} }

          product.images = "---\r\n- https://placeimg.com/300/300/any"
        end

        puts '  Index data'
        retry_count = 0
        begin
          Product.searchkick_index.delete rescue nil
          Product.reindex
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
