FactoryBot.define do
  factory :contact_list do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :active do
      status { ContactList.status_active }
    end

    trait :with_email_optin do
      email_optin { 'Yes' }
    end

    trait :without_email_optin do
      email_optin { 'No' }
    end

    trait :for_network do
      owner { build :network }
    end
  end
end
