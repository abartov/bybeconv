# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { Faker::Book.title }
    sort_title { title }
    subtitle { Faker::Book.title }
    issn { 'MyString' }
    collection_type { %w(volume periodical periodical_issue series other).sample }

    transient do
      authors { [] }
      translators { [] }
      editors { [] }
      included_collections { [] }
      manifestations { [] }
    end

    involved_authorities do
      result = []
      if authors.present?
        result += authors.map { |authority| build(:involved_authority, authority: authority, role: :author) }
      end
      if translators.present?
        result += translators.map { |authority| build(:involved_authority, authority: authority, role: :translator) }
      end
      if editors.present?
        result += editors.map { |authority| build(:involved_authority, authority: authority, role: :editor) }
      end
      result
    end

    collection_items do
      (included_collections + manifestations).map { |item| build(:collection_item, item: item) }
    end
  end
end
