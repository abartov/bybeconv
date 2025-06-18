# frozen_string_literal: true

FactoryBot.define do
  factory :featured_content do
    user { create(:user) }
    authority { create(:authority) }
    title { Faker::Book.title }
    body { Faker::Lorem.paragraph }
    external_link { Faker::Internet.url }
    featured_content_features { build_list(:featured_content_feature, 1) }
  end
end
