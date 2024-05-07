FactoryBot.define do
  factory :manifestation do
    transient do
      sequence(:manifestation_name) { |n| "Manifestation #{n}" }
      author { create(:person, toc: create(:toc)) }
      language { 'he' }
      orig_lang { %w(he en ru de it).sample }
      genre { Work::GENRES.sample }
      period { Expression.periods.keys.sample }
      translator { orig_lang.to_s == language.to_s ? nil : create(:person) }
      editor { nil }
      illustrator { nil }
      intellectual_property { :public_domain }
      expression_title { title }
      work_title { title }
      primary { true }
      expression_date { '2 ביוני 1960' }
      work_date { '3 ביוני 1960' }
    end

    title { "Title for #{manifestation_name}" }
    publisher { Faker::Company.name }
    publication_place { Faker::Address.city }
    publication_date { '2019-01-01' }
    comment { "Comment for #{manifestation_name}" }
    markdown { "Markdown for #{manifestation_name}" }
    impressions_count { Random.rand(100) }
    status { :published }

    expression do
      create(
        :expression,
        author: author,
        title: expression_title,
        work_title: work_title,
        translator: translator,
        editor: editor,
        illustrator: illustrator,
        language: language,
        orig_lang: orig_lang,
        genre: genre,
        period: period,
        intellectual_property: intellectual_property,
        primary: primary,
        date: expression_date,
        work_date: work_date
      )
    end

    trait :with_external_links do
      external_links { build_list(:external_link, 2) }
    end

    trait :with_recommendations do
      recommendations { build_list(:recommendation, 3) }
    end
  end
end
