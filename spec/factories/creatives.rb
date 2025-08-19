FactoryBot.define do
  factory :creative do
    offer_variant

    trait :for_image_creative do
      association :entity, factory: :image_creative
    end

    trait :for_text_creative do
      association :entity, factory: :text_creative
    end
  end
end
