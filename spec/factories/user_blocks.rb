FactoryBot.define do
  factory :user_block do
    user { nil }
    context { "MyString" }
    expires_at { "2023-11-29 22:28:11" }
    blocker_id { 1 }
    reason { "MyString" }
  end
end
