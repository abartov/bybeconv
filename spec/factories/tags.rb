FactoryBot.define do
  factory :tag do
    status { :approved }
    name { "MyString #{Time.now} #{rand(1000)}" }
    creator { create(:user)}
  end
  trait :pending do
    status { :pending }
  end
end

