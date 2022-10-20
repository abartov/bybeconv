class DictionaryEntry < ApplicationRecord
  paginates_per 100
  belongs_to :manifestation
  has_many :from_links, class_name: :DictionaryLink, foreign_key: :from_entry_id, dependent: :destroy
  has_many :to_links, class_name: :DictionaryLink, foreign_key: :to_entry_id, dependent: :destroy
  has_many :aliases, class_name: :DictionaryAlias, foreign_key: :dictionary_entry_id, dependent: :destroy
  has_many :incoming_links, class_name: :DictionaryEntry, through: :from_links, source: :to_entry
  has_many :outgoing_links, class_name: :DictionaryEntry, through: :to_links, source: :from_entry

  def get_next_defs(quantity)
    get_neighboring_defs(quantity, true)
  end
  def get_prev_defs(quantity)
    get_neighboring_defs(quantity, false)
  end
  def delta_to(another_def)
    return 0 if another_def.nil?
    return another_def.sequential_number - sequential_number # earlier defs will return a negative delta, and later defs a positive one, intuitively
  end
  def self.cached_count
    Rails.cache.fetch("m_dict_count", expires_in: 24.hours) do
      self.where("defhead is not null").count
    end
  end

  protected
  def get_neighboring_defs(quantity, forward)
    if forward
      return DictionaryEntry.where('manifestation_id = ? and sequential_number > ? and defhead is not null', manifestation_id, sequential_number).order(sequential_number: :asc).limit(quantity)
    else
      return DictionaryEntry.where('manifestation_id = ? and sequential_number < ? and defhead is not null', manifestation_id, sequential_number).order(sequential_number: :desc).limit(quantity) # TODO: this will be slow until we upgrade to MySQL 8.x which supports desc indexing
    end
  end
end
