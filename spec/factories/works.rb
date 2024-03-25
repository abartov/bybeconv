FactoryBot.define do

  factory :work do
    transient do
      sequence(:work_name) { |n| "Work #{n}" }
      author { create(:person) }
      illustrator { nil }
    end

    title { "Title for #{work_name}" }
    date { '3 ביוני 1960' }
    comment { "Comment for #{work_name}" }
    genre { Work::GENRES.sample }
    orig_lang { %w(he en ru de it).sample }
    origlang_title { "Title in original language for #{work_name}" }
    normalized_pub_date {}
    normalized_creation_date { normalize_date(date) }
    primary { true }
    involved_authorities do
      result = [build(:involved_authority, authority: author, role: :author)]
      if illustrator.present?
        result << build(:involved_authority, authority: illustrator, role: :illustrator)
      end
      result
    end
  end
end
