FactoryBot.define do
  sequence :manifestation_number do |n|
    "Manifestation #{n}"
  end

  factory :manifestation do
    transient do
      number { generate(:manifestation_number) }
    end

    title { "Title for #{number}" }
    publisher { "Publisher for #{number}" }
    publication_place { "Publication place for #{number}" }
    publication_date { '2019-01-01' }
    comment { "Comment for #{number}" }
    markdown { "Markdown for #{number}" }
    impressions_count { 4 }
    status { :published }

    expressions { [ create(:expression) ] }
  end
end
