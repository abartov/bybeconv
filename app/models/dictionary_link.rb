class DictionaryLink < ApplicationRecord
  belongs_to :from_entry, class: :DictionaryEntry
  belongs_to :to_entry, class: :DictionaryEntry
end
