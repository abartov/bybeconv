FactoryBot.define do
  factory :dictionary_entry do
    manifestation
    defhead { Faker::Book.title }
    deftext { Faker::Quotes::Shakespeare.hamlet_quote }
  end
end
