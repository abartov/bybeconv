# frozen_string_literal: true

FactoryBot.define do
  factory :ingestible do
    title { Faker::Book.title }
    status { 'draft' }
    no_volume { true }
    credits { Faker::Lorem.sentence }
    markdown { "&&& #{Faker::Book.title} \n#{Faker::Lorem.paragraph}" }
    trait :with_volume do
      no_volume { false }
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
    trait :with_footnotes do
      markdown do
        "&&& כותרת ראשונה\n\nטקסט עם הערת שוליים[^1].\n\n[^1]: הערת שוליים ראשונה\n\n&&& כותרת שנייה\n\nטקסט עם הערת שוליים[^1].\n\n[^1]: הערת שוליים שנייה"
      end
    end
  end
end
