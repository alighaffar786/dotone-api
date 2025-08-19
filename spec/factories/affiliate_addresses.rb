FactoryBot.define do
  factory :affiliate_address do
    address_1 { Faker::Address.street_address }
    address_2 { Faker::Address.building_number }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code }
    country factory: :country_united_states
  end
end
