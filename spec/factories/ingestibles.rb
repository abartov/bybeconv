# frozen_string_literal: true

FactoryBot.define do
  factory :ingestible do
    title { Faker::Book.title }
    status { 'draft' }
    markdown { Faker::Lorem.paragraph }
    trait :with_buffers do
      works_buffer do
        5.times.map do
          {
            title: Faker::Book.title,
            content: Faker::Lorem.paragraph
          }
        end.to_json
      end
    end
  end
end
