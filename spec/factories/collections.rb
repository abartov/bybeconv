# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { Faker::Book.title }
    sort_title { title }
    subtitle { Faker::Book.title }
    issn { 'MyString' }
    collection_type { %w(volume periodical periodical_issue series other).sample }
  end
end
