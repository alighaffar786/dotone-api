FactoryBot.define do
  factory :country do
    name { 'United States' }
    iso_2_country_code { 'US' }
    iso_3_country_code { 'USA' }
    initialize_with { Country.find_or_create_by(iso_2_country_code: 'US') }
  end

  factory :country_united_states, :class => Country do
    name { 'United States' }
    iso_2_country_code { 'US' }
    iso_3_country_code { 'USA' }
  end

  factory :country_canada, :class => Country do
    name { 'Canada' }
    iso_2_country_code { 'CA' }
    iso_3_country_code { 'CAN' }
  end

  factory :country_with_random_name, :class => Country do
    name { Faker::Lorem.words(1).first }
    iso_2_country_code { 'XX' }
    iso_3_country_code { 'XXX' }
  end
end
