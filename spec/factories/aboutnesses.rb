FactoryBot.define do
  factory :aboutness do
    user { create(:user) }
    work { create(:manifestation).expression.work }
  end
end
