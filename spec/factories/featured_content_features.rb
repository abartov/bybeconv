# frozen_string_literal: true

FactoryBot.define do
  factory :featured_content_feature do
    fromdate { rand(30).days.ago }
    todate { fromdate + rand(60).days }
  end
end
