FactoryBot.define do
  factory :collection do
    title { "MyString" }
    sort_title { "MyString" }
    subtitle { "MyString" }
    issn { "MyString" }
    collection_type { 1 }
    inception { "MyString" }
    inception_year { 1 }
    publication { nil }
    toc { nil }
    toc_strategy { 1 }
  end
end
