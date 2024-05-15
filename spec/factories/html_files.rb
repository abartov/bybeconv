# frozen_string_literal: true

FactoryBot.define do
  factory :html_file do
    status { 'Accepted' }
    title { "#{Faker::Lorem.sentence}." }
    genre { Work::GENRES.sample }
    publisher { Faker::Company.name }
    author { create(:authority) }
    translator { create(:authority) }
  end
end
