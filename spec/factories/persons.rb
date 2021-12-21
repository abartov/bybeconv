FactoryBot.define do
  factory :person do
    name { Faker::Name.name }
    gender { 'male' }
    period { 'revival' }
    other_designation { Faker::Name.name_with_middle }
    wikipedia_snippet { Faker::Quotes::Shakespeare.hamlet_quote }
    impressions_count { Random.rand(200) }
  end
end
