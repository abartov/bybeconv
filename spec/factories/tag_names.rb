FactoryBot.define do
  factory :tag_name do
    tag { create(:tag) }
    name { "MyString #{Time.now} #{rand(1000)}" }
  end
end
