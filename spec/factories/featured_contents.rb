# frozen_string_literal: true

FactoryBot.define do
  factory :featured_content do
    user { create(:user) }
    authority { create(:authority) }
    title { Faker::Book.title }
    body { Faker::Lorem.paragraph }
    external_link { Faker::Internet.url }
  end
end
