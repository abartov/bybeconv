FactoryBot.define do
  factory :tag_name do
    tag { create(:tag) }
    name { "MyString" }
  end
end
