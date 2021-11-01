FactoryBot.define do
  sequence :api_key_email do |n|
    "api_user_#{n}@test.com"
  end

  factory :api_key do
    email { generate(:api_key_email) }
    description { 'API Key Description' }
    status { :enabled }
    key { Random.hex(32) }
  end
end