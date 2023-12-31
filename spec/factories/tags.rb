FactoryBot.define do
  factory :tag do
    transient do
      sequence(:tagname) { |n| "Tag #{n} #{Time.now}" }
    end
    status { :approved }
    name { "#{tagname}" }
    creator { create(:user)}
  end
  trait :pending do
    status { :pending }
  end
end

