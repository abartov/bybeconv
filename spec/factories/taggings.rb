FactoryBot.define do
  factory :tagging do
    status { :pending }
    suggester { create(:user)}
    tag { create(:tag)}
    taggable { create(:manifestation)}
  end
end
