FactoryBot.define do
  factory :affiliate_payment do
    affiliate

    transient do
      with_payment_fee { nil }
    end

    trait :deferred do
      status { AffiliatePayment.status_deferred }
    end

    trait :redeemable do
      status { AffiliatePayment.status_redeemable }
    end

    after(:create) do |affiliate_payment, evaluator|
      create(:affiliate_payment_info, affiliate: affiliate_payment.affiliate)

      if evaluator.with_payment_fee
        create(:payment_fee,
          affiliate_payment: affiliate_payment,
          amount: evaluator.with_payment_fee)
      end
    end
  end
end
