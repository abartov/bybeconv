# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    status { :approved }
    name { Faker::Lorem.unique.word }
    creator { create(:user) }
  end

  trait :pending do
    status { :pending }
  end
end

