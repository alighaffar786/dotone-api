FactoryBot.define do
  factory :offer_variant do
    name { Faker::Name.name }
    sequence(:description) { |x| "Offer Variant Description #{x}" }
    sequence(:destination_url) { |x| 'https://testoffervariantdomain#{x}.com/?param1=#{x}' }
    status { OfferVariant::STATUS_ACTIVE_PUBLIC }
    is_default { true }
    association :offer, factory: :network_offer
    language { Language.find_by_code('en-US') || create(:language, :en_us) }

    trait :for_cps do
      association :offer, factory: [:network_offer, :for_cps]
    end

    trait :for_cpl do
      association :offer, factory: [:network_offer, :for_cpl]
    end
  end
end
