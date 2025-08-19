FactoryBot.define do
  factory :category do
    name { FactoryBot.generate(:name) }
    category_group
  end
end
