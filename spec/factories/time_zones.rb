FactoryBot.define do
  factory :time_zone do
    gmt { Faker::Number.decimal }
    name { FactoryBot.generate(:name) }
    gmt_string { "+00:00" }

    trait "+00:00" do
      gmt { 0.00 }
      gmt_string { "+00:00" }
    end

    trait "+08:00" do
      gmt { 8.00 }
      gmt_string { "+08:00" }
    end
  end
end
