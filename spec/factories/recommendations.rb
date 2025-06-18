FactoryBot.define do
  factory :recommendation do
    user
    manifestation
    status { :approved }
    body { Faker::Quote.yoda }
  end
end

