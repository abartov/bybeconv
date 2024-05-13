# frozen_string_literal: true

FactoryBot.define do
  factory :html_file do
    status { 'Accepted' }
    title { "#{Faker::Lorem.sentence}." }
    genre { Work::GENRES.sample }
    publisher { Faker::Company.name }
    person { create(:person) }
    translator { create(:person) }
  end
end
