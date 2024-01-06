FactoryBot.define do
  factory :collection_item do
    collection { create(:collection) }
    alt_title { "MyString" }
    context { "MyText" }
    seqno { 1 }
    item { nil }
  end
end
