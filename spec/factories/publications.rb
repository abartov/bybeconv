FactoryBot.define do
  factory :publication do
    authority
    bib_source
    title { Faker::Book.title }
    publisher_line { Faker::Company.name }
    author_line { Faker::Name.name_with_middle }
    status { :uploaded }
    pub_year { 'תר"ס 1900' }
    language { 'heb' }

    trait :pubs_maybe_done do
      after :create do |pub|
        create(:list_item, item: pub, listkey: :pubs_maybe_done)
      end
    end
  end
end
