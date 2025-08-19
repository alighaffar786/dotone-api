FactoryBot.define do
  factory :network_offer, aliases: [:offer] do
    name { Faker::Name.name }
    need_approval { true }
    destination_url { Faker::Internet.url }
    approval_message { 'Some Approval Message' }
    package_name { 'com.sample.rspec' }
    click_geo_filter { false }

    network

    trait :for_cps do
      conversion_point { 'Multi' }
      after(:create) do |offer, _|
        create_list(:conversion_step, 1, :for_cps, offer: offer)
        offer.reload
      end
    end

    trait :for_cpl do
      after(:create) do |offer, _|
        create_list(:conversion_step, 1, :for_cpl, offer: offer)
        offer.reload
      end
    end

    transient do
      generate_offer_variant { true }
      with_offer_tag { nil }
    end

    after(:create) do |offer, evaluator|
      if evaluator.generate_offer_variant
        create(:offer_variant, offer: offer, name: nil)
        offer.reload
      end

      category = FactoryBot.create(:category)
      FactoryBot.create(:offer_category, category: category, offer: offer)

      create(:owner_has_tag, evaluator.with_offer_tag, owner: offer) if evaluator.with_offer_tag
    end
  end
end
