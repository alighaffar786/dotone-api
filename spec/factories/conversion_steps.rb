FactoryBot.define do
  factory :conversion_step do
    name { %w[default sale].sample }
    label { name.capitalize }
  end
end
