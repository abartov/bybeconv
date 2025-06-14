# frozen_string_literal: true

FactoryBot.define do
  factory :base_user do
    session_id { Random.hex(32) if user.nil? }

    trait :registered do
      user
    end

    trait :unregistered do
      # Use this trait if you need a record in sessions table for unregistered user
      session_id { create(:session).session_id }
    end

    trait :with_bookmarks do
      transient do
        bookmarks_count { 1 }
      end

      after(:create) do |bu, evaluator|
        create_list(:bookmark, evaluator.bookmarks_count, base_user: bu)
      end
    end

    trait :with_preferences do
      after(:create) do |bu|
        bu.set_preference(:fontsize, Random.rand(10..15))
        bu.set_preference(:accepted_tag_policy, Random.rand(1))
      end
    end
  end
end
