FactoryBot.define do
  factory :corporate_body do
    name { "MyString" }
    alternate_names { "MyString" }
    location { "MyString" }
    inception { "MyString" }
    inception_year { 1 }
    dissolution { "MyString" }
    dissolution_year { 1 }
    wikidata_uri { "MyString" }
    viaf_id { "MyString" }
    comments { "MyText" }
  end
end
