# frozen_string_literal: true

FactoryBot.define do
  factory :ingestible do
    title { Faker::Book.title }
    status { 'draft' }
    markdown { Faker::Lorem.paragraph }
  end
end
