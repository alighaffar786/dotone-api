FactoryBot.define do
  factory :affiliate_payment_info do
    affiliate

    after(:create) do |affiliate_payment_info, _evaluator|
      create(:affiliate_address, affiliate: affiliate_payment_info.affiliate)
    end
  end
end
