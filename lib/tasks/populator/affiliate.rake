require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliates'
    task :affiliates, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Affiliates'

        # Full cleanup
        puts '  Destroy old data'
        [
          Affiliate,
          AffiliateApplication,
          SiteInfo,
          SiteInfoCategoryGroup,
          AffiliateSite,
          AffiliateAddress,
        ].each do |klass|
          klass.delete_all
        end

        password = "affiliate$#{Date.today.year}$#{Date.today.month}"
        crypted_password = DotOne::Utils::Encryptor.encrypt(password)
        email_index = 0

        category_groups = CategoryGroup.all.to_a
        countries = Country.all.to_a
        affiliates = Affiliate.all.to_a
        language = Language.default

        puts '  Generate affiliates data'
        Affiliate.populate 100 do |affiliate|
          affiliate.username = Faker::Internet.user_name
          affiliate.crypted_password = crypted_password
          affiliate.time_zone_id = TimeZone.all.sample
          affiliate.email = "affiliate#{email_index += 1}@converly.com"
          affiliate.first_name = Faker::Name.first_name
          affiliate.last_name = Faker::Name.last_name
          affiliate.status = Affiliate.status_active
          affiliate.created_at = 10.days.ago..Time.now
          affiliate.payment_term = Affiliate::PAYMENT_TERM_ONCE_A_MONTH
          affiliate.traffic_quality_level = [0, 1, 2, 3, 4, 5].sample
          affiliate.business_entity = ['Individual', 'Company'].sample
          affiliate.tax_filing_country = ['Taiwan', 'United States'].sample
          affiliate.login_count = rand(1..50)
          affiliate.last_request_at = Time.now - rand(1..100).days
          affiliate.ranking = rand(1..10)
          affiliate.experience_level = rand(6)
          affiliate.traffic_quality_level = rand(6)
          affiliate.currency_id = 1
          affiliate.referrer_id = (1..100).to_a.sample
          affiliate.email_verified = true
          affiliate.language_id = language.id

          unique_token = DotOne::Utils::Encryptor.encrypt(affiliate.username + Time.now.to_s)
          unpacked = unique_token.unpack('H*')
          unique_token = unpacked.first

          affiliate.unique_token = unique_token

          AffiliateApplication.populate 1 do |app|
            company_name = (Faker::Company.name if affiliate.business_entity == 'Company')

            app.affiliate_id = affiliate.id
            app.phone_number = Faker::PhoneNumber.phone_number
            app.company_name = company_name
            app.status = AffiliateApplication::STATUS_BRAND_NEW
            app.accept_terms = true
            app.accept_terms_at = Time.now
            app.age_confirmed = true
            app.age_confirmed_at = Time.now

            SiteInfo.populate 2 do |site_info|
              site_info.url = Faker::Internet.url
              site_info.description = Faker::Lorem.sentence
              site_info.comments = Faker::Lorem.sentence
              site_info.unique_visit_per_day = '10,001 - 100,000'
              site_info.affiliate = affiliate

              SiteInfoCategoryGroup.populate 2 do |sicc|
                sicc.category_group_id = category_groups.rotate!.first.id
                sicc.site_info_id = site_info.id
              end
            end
          end

          # Populate affiliate address
          puts '  Generate affiliate address'
          AffiliateAddress.populate 1 do |address|
            address.address_1 = Faker::Address.street_address
            address.city = Faker::Address.city
            address.state = Faker::Address.state
            address.zip_code = Faker::Address.zip_code
            address.country_id = countries.rotate!.first.id
            address.affiliate_id = affiliate.id
          end
        end
      end
    end
  end
end
