FactoryBot.define do
  factory :text_creative do
    transient do
      offer_variant { create(:offer_variant) }
    end
    
    active_date_start { Time.now }
    active_date_end { Time.now + 1.week }
    creative_name { Faker::Lorem.word }
    title { Faker::Lorem.word }
    content_1 { Faker::Lorem.word }
    custom_landing_page { Faker::Internet.url }
    status { VibrantConstant::Status::PENDING }
    button_text { 'Click Me' }
    deal_scope { 'Entire Store' }

    after(:create) do |text_creative, evaluator|
      create_list(:creative, 1, :for_text_creative, {
        entity: text_creative,
        offer_variant: evaluator.offer_variant
      })
    end
  end
end
