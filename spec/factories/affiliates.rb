FactoryBot.define do
  factory :affiliate do
    language factory: %i[language en_us]
    email { Faker::Internet.email }
    status { 'Active' }
    password { 'changeme' }
  end
end
