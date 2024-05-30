# frozen_string_literal: true

FactoryBot.define do
  factory :featured_content_feature do
    fromdate { 5.days.ago }
    todate { 5.days.from_now }
  end
end
