# frozen_string_literal: true

FactoryBot.define do
  factory :featured_author do
    user { create(:user) }
    person { create(:authority).person }
    featurings { create_list(:featured_author_feature, 1) }
    title { Faker::Artist.name }
    body { Faker::Lorem.paragraph }
  end
end
