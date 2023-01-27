FactoryBot.define do
  factory :anthology_text do
    anthology { create(:anthology) }
    manifestation { create(:manifestation) }
    sequence(:title) { |n| "title #{n}" }
  end
end
