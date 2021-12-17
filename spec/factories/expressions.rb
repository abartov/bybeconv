FactoryBot.define do
  sequence :expression_number do |n|
    "Expression #{n}"
  end

  factory :expression do
    transient do
      number { generate(:expression_number) }
      author { create(:person) }
      orig_lang { %w(he en ru de it).sample }
      translator { orig_lang != 'he' ? create(:person) : nil }
      editor { nil }
      illustrator { nil }
    end
    title { "Title for #{number}" }
    form {}
    date { '2 ביוני 1960' }
    language {}
    comment { "Comment for #{number}" }
    copyrighted { 0 }
    copyright_expiration { nil }
    genre { Work::GENRES.sample }
    translation {}
    source_edition {}
    period { Expression.periods.keys.sample }
    works { [ create(:work, genre: genre, author: author, orig_lang: orig_lang) ] }
    realizers do
      result = []
      if orig_lang != 'he'
        result << create(:realizer, person: translator, role: :translator)
      end
      if editor.present?
        result << create(:realizer, person: editor, role: :editor)
      end
      if illustrator.present?
        result << create(:realizer, person: illustrator, role: :illustrator)
      end
      result
    end
  end
end
