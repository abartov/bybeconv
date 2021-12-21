FactoryBot.define do
  factory :recommendation do
    status { :approved }
    body { Faker::Quote.yoda }
  end
end

