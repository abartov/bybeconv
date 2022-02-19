FactoryBot.define do
  factory :bib_source do
    title { Faker::Book.title }
    source_type { :googlebooks }
    url { Faker::Internet.url }
    status { :enabled }
  end
end