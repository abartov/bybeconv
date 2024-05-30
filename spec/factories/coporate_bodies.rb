# frozen_string_literal: true

FactoryBot.define do
  factory :corporate_body do
    dissolution_year { rand(1970..2020) }
    dissolution { dissolution_year.to_s }
    inception_year { dissolution_year - rand(30) }
    inception { inception_year.to_s }
    location { Faker::Address.city }
  end
end
