FactoryBot.define do
  sequence :manifestation_number do |n|
    "Manifestation #{n}"
  end

  factory :manifestation do
    transient do
      number { generate(:manifestation_number) }
      author { create(:person) }
      orig_lang { %w(he en ru de it).sample }
      translator { orig_lang != 'he' ? create(:person) : nil }
      editor { nil }
      illustrator { nil }
    end

    title { "Title for #{number}" }
    publisher { Faker::Company.name }
    publication_place { Faker::Address.city }
    publication_date { '2019-01-01' }
    comment { "Comment for #{number}" }
    markdown { "Markdown for #{number}" }
    impressions_count { 4 }
    status { :published }

    expressions { [ create(:expression, author: author, translator: translator, editor: editor, illustrator: illustrator, orig_lang: orig_lang) ] }

    trait :with_external_links do
      external_links { build_list(:external_link, 2) }
    end

    trait :with_recommendations do
      recommendations { build_list(:recommendation, 3) }
    end
  end
end
