# frozen_string_literal: true

FactoryBot.define do
  factory :authority do
    transient do
      gender { 'male' }
      period { 'revival' }
    end

    name { Faker::Name.name }
    status { :published }
    other_designation { Faker::Name.name_with_middle }
    wikipedia_snippet { Faker::Quotes::Shakespeare.hamlet_quote }
    impressions_count { Random.rand(200) }
    intellectual_property { :public_domain }

    person { create(:person, gender: gender, period: period) }
  end
end
