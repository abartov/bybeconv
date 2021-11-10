FactoryBot.define do
  sequence :expression_number do |n|
    "Expression #{n}"
  end

  factory :expression do
    transient do
      number { generate(:expression_number) }
    end
    title { "Title for #{number}" }
    form {}
    date { '2 ביוני 1960' }
    language {}
    comment { "Comment for #{number}" }
    copyrighted { 0 }
    copyright_expiration { nil }
    genre { 'prose' }
    translation {}
    source_edition {}
    period { :modern }
    works { [ create(:work, genre: genre) ] }
  end
end
