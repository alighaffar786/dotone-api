# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :category_group do
    sequence(:name) { |x| "Category Group #{x}" }
  end
end
