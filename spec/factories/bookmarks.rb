FactoryBot.define do
  factory :bookmark do
    base_user { create(:base_user) }
    bookmark_p { 'PATH' }
  end
end
