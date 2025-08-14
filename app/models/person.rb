include BybeUtils
class Person < ApplicationRecord
  include LifePeriod

  enum :gender, { male: 0, female: 1, other: 2, unknown: 3 }
  enum :period, { ancient: 0, medieval: 1, enlightenment: 2, revival: 3, modern: 4 }
  has_one :authority, inverse_of: :person, dependent: :destroy

  scope :with_name, -> { joins(:authority).select('people.*, authorities.name') }

  has_paper_trail

  def gender_letter
    return gender == 'female' ? 'ה' : 'ו'
  end

  def blog_count
    return 0 # TODO: implement
  end

  def period_string
    return '' if period.nil?
    return t(period)
  end
end
