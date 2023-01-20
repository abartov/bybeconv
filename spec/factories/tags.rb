FactoryBot.define do
  factory :tag do
    status { :pending }
    name { "MyString" }
    creator { create(:user)}
  end
end

