FactoryBot.define do
  factory :holding do
    status { :scanned }
    scan_url { Faker::Internet.url }
  end
end