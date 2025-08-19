FactoryBot.define do
  factory :image do
    url { Faker::Internet.url }

    trait :for_network do
      owner { build :network }
    end
  end
end
