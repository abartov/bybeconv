FactoryBot.define do
  sequence :work_number do |n|
    "Work #{n}"
  end

  factory :work do
    transient do
      number { generate(:work_number) }
    end

    title { "Title for #{number}" }
    date { '3 ביוני 1960' }
    comment { "Comment for #{number}" }
    genre { Work::GENRES.sample }
    orig_lang { %w(he en ru de it).sample }
    origlang_title { "Title in original language for #{number}" }
    normalized_pub_date {}
    normalized_creation_date { normalize_date(date) }
    creations { [create(:creation, person: create(:person), role: :author)] }
  end
end
