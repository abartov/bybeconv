FactoryBot.define do
  factory :tagging do
    status { :pending }
    suggester { create(:user)}
    tag { create(:tag)}
    manifestation { create(:manifestation)}
  end
end
