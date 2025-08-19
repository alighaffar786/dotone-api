FactoryBot.define do
  factory :payment_fee do
    affiliate_payment
    label { Faker::Lorem.word }
  end
end
