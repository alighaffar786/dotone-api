FactoryBot.define do
  factory :network do
    name { Faker::Company.name }
    contact_name { Faker::Name.name }
    contact_email { Faker::Internet.email }
    contact_title { Faker::Name.name }
    contact_phone { Faker::PhoneNumber.phone_number }
    company_url { Faker::Internet.url }
    username { Faker::Internet.username }
    password { Faker::Internet.password }
    password_confirmation { password }
    iso_2_country_code { Faker::Address.country_code }
    locale_code { 'en-US' }
    language { Language.find_by_code('en-US') || create(:language, :en_us) }

    trait :active do
      status { VibrantConstant::Status::ACTIVE }
    end
  end
end
