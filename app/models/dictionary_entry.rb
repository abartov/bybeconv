class DictionaryEntry < ApplicationRecord
  paginates_per 100
  belongs_to :manifestation
end
