# frozen_string_literal: true

FactoryBot.define do
  factory :involved_authority do
    authority { create(:authority) }
    role { :author }
  end
end
