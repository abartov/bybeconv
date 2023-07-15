FactoryBot.define do
  factory :tag do
    status { :approved }
    name { "MyString" }
    creator { create(:user)}
  end
  trait :pending do
    status { :pending }
  end
end

