class DictionaryLink < ApplicationRecord
  belongs_to :from_entry, class_name: :DictionaryEntry
  belongs_to :to_entry, class_name: :DictionaryEntry
end
