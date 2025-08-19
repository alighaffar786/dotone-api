FactoryBot.define do
  factory :image_creative do
    transient do
      offer_variant { create(:offer_variant) }
    end

    internal { false }
    cdn_url { Faker::Internet.url }
    locale { %w[zh-TW en-US].sample }
    status { ImageCreative.status_pending }

    trait :active do
      status { ImageCreative.status_active }
    end

    trait :pending do
      status { ImageCreative.status_pending }
    end

    trait :rejected do
      status { ImageCreative.status_rejected }
      status_reason { Faker::Lorem.sentence }
    end

    after(:create) do |image_creative, evaluator|
      create_list(:creative, 1, :for_image_creative, {
        entity: image_creative,
        offer_variant: evaluator.offer_variant
      })
    end
  end
end
