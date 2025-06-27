# frozen_string_literal: true

FactoryBot.define do
  factory :ahoy_visit, class: 'Ahoy::Visit' do
    started_at { Time.now - Random.rand(240).minutes }
  end
end
