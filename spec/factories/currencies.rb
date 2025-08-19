FactoryBot.define do
  factory :currency do
    name { 'US Dollar' }
    code { 'USD' }

    trait :us_dollar do
      name { 'US Dollar' }
      code { 'USD' }
    end
  end
end
