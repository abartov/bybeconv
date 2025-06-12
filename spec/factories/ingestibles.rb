# frozen_string_literal: true

FactoryBot.define do
  factory :ingestible do
    title { Faker::Book.title }
    status { 'draft' }
    no_volume {true}
    markdown { Faker::Lorem.paragraph }
    trait :with_volume do
      no_volume {false}
      prospective_volume_id { create(:collection).id }
    end
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
