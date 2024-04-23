FactoryBot.define do
  factory :corporate_body do
    name { Faker::Name.name }
    status { CorporateBody.statuses.keys.sample }
    alternate_names { Faker::Name.name }
    location { Faker::Address.country }
    inception { 'long time ago' }
    inception_year { 1950 + Random.rand(70) }
    dissolution { nil }
    dissolution_year { inception_year + Random.rand(10) }
    wikidata_uri { Faker::Internet::url }
    wikipedia_url { Faker::Internet::url }
    wikipedia_snippet { Faker::Books::Lovecraft.paragraph }
    viaf_id { 'VIAF' }
    nli_id { 'NLI' }
    comments { Faker::Books::Lovecraft.paragraph }
  end
end
