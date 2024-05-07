# frozen_string_literal: true

FactoryBot.define do
  factory :involved_authority do
    person { create(:person) }
    role { :author }
  end
end
