# frozen_string_literal: true

FactoryBot.define do
  factory :collection_item do
    collection { create(:collection) }
    alt_title { nil }
    markdown { nil }

    seqno { 1 }
    item { nil }
  end
end
