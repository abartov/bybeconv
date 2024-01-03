FactoryBot.define do
  factory :expression do
    transient do
      sequence(:expression_name) { |n| "Expression #{n}" }
      author { create(:person) }
      orig_lang { %w(he en ru de it).sample }
      translator { orig_lang != 'he' ? create(:person, gender: %w(male female).sample) : nil }
      editor { nil }
      illustrator { nil }
      genre { Work::GENRES.sample }
      work_title { title }
      primary { true }
    end
    title { "Title for #{expression_name}" }
    form {}
    date { '2 ביוני 1960' }
    language { 'he' }
    comment { "Comment for #{expression_name}" }
    copyrighted { false }
    copyright_expiration { nil }
    translation { orig_lang != language }
    source_edition {}
    period { Expression.periods.keys.sample }
    work { create(:work, genre: genre, author: author, illustrator: illustrator, orig_lang: orig_lang) }
    involved_authorities do
      result = []
      if orig_lang != 'he'
        result << build(:involved_authority, authority: translator, role: :translator)
      else
        if translator.present?
          #raise "Cannot specify translator if language matches orig_lang - lang: #{language} orig_lang: #{orig_lang} translator: #{translator}"
        end
      end
      if editor.present?
        result << build(:involved_authority, authority: editor, role: :editor)
      end
      result
    end
  end
end
