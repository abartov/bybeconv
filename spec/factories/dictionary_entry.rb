FactoryBot.define do
  factory :dictionary_entry do
    defhead { Faker::Book.title }
    deftext { Faker::Quotes::Shakespeare.hamlet_quote }
  end
end
