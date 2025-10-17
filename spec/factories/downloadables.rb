# frozen_string_literal: true

FactoryBot.define do
  factory :downloadable do
    doctype { :pdf }
    association :object, factory: :manifestation

    trait :with_file do
      after(:create) do |downloadable|
        downloadable.stored_file.attach(
          io: StringIO.new('test content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end
    end

    trait :without_file do
      # Downloadable without any attachment
    end
  end
end
