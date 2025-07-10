FactoryBot.define do
  factory :proof do
    from { Faker::Internet.email }
    highlight { Faker::Quotes::Shakespeare.hamlet_quote }
    what { Faker::Quotes::Shakespeare.romeo_and_juliet_quote }
    status { Proof::STATUSES.sample }
    item { create(:manifestation) }
  end
end
