FactoryBot.define do
  sequence :person_name do |n|
    "Person #{n}"
  end

  factory :person do
    name { generate(:person_name) }
    gender { 'male' }
  end
end
