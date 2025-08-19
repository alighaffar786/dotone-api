require 'faker'
require 'populator'
require 'open-uri'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :affiliate_users, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Affiliate Users'

        puts '  Destroy old data'
        [WlaRelation, AffiliateUser, AffiliateAssignment].each do |klass|
          klass.delete_all
        end

        # Prepare avatar images from some online resources
        puts '  Prepare avatar images'
        image_path = "#{RakeWl::CDN_BASE_PATH}/affiliate_users"
        avatars = []
        1.upto(20) do |idx|
          avatars << "#{image_path}/profile-#{idx}.png"
        end

        [
          { email: 'network.manager@converly.com', role: 'Network Manager' },
          { email: 'affiliate.director@converly.com', role: 'Affiliate Director' },
          { email: 'affiliate.manager@converly.com', role: 'Affiliate Manager' },
          { email: 'event.manager@converly.com', role: 'Event Manager' },
          { email: 'sales.director@converly.com', role: 'Sales Director' },
          { email: 'sales.manager@converly.com', role: 'Sales Manager' },
          { email: 'ops.team@converly.com', role: 'Ops Team' },
          { email: 'designer@converly.com', role: 'Designer' },
        ].each do |info|
          puts "  Generate #{info}"
          AffiliateUser.populate 1 do |ap|
            ap.email = info[:email]
            ap.direct_phone = Faker::PhoneNumber.phone_number
            ap.mobile_phone = Faker::PhoneNumber.phone_number
            ap.fax = Faker::PhoneNumber.phone_number
            ap.username = Faker::Internet.user_name
            ap.line = Faker::Internet.user_name
            ap.skype = Faker::Internet.user_name
            ap.wechat = Faker::Internet.user_name
            ap.qq = Faker::Internet.user_name
            ap.crypted_password = DotOne::Utils::Encryptor.encrypt("admin$#{Date.today.year}$#{Date.today.month}")
            ap.time_zone_id = TimeZone.all.sample
            ap.first_name = Faker::Name.first_name
            ap.last_name = Faker::Name.last_name
            ap.status = AffiliateUser.status_active
            ap.unique_token = DotOne::Utils::Encryptor.encrypt(ap.username + Time.now.to_s)
            ap.roles = info[:role]
            ap.currency_id = 1
            ap.avatar_cdn_url = avatars.rotate!.first
          end
        end
      end
    end
  end
end
