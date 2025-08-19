FactoryBot.define do
  factory :language do
    trait :en_us do
      name { 'English' }
      code { 'en-US' }
      initialize_with { Language.find_or_create_by(code: 'en-US') }
    end
  end
end
