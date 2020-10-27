class DictionaryEntry < ApplicationRecord
  paginates_per 100
  belongs_to :manifestation

  def get_next_defs(quantity)
    get_neighboring_defs(quantity, true)
  end
  def get_prev_defs(quantity)
    get_neighboring_defs(quantity, false)
  end
  def delta_to(another_def)
    return another_def.sequential_number - sequential_number # earlier defs will return a negative delta, and later defs a positive one, intuitively
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
