FactoryBot.define do
  factory :person do
    name { Faker::Name.name }
    status { :published }
    gender { 'male' }
    period { 'revival' }
    other_designation { Faker::Name.name_with_middle }
    wikipedia_snippet { Faker::Quotes::Shakespeare.hamlet_quote }
    impressions_count { Random.rand(200) }
    intellectual_property { :public_domain }
  end
end
