FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    provider { 'google_oauth2' }
    admin { 0 }
    editor { 0 }
  end
end
