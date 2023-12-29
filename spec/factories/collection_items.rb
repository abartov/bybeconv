FactoryBot.define do
  factory :collection_item do
    collection { nil }
    alt_title { "MyString" }
    context { "MyText" }
    seqno { 1 }
    item { nil }
  end
end
