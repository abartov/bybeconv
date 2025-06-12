include BybeUtils
class Person < ApplicationRecord
  enum gender: { male: 0, female: 1, other: 2, unknown: 3 }
  enum period: { ancient: 0, medieval: 1, enlightenment: 2, revival: 3, modern: 4 }
  has_one :authority, inverse_of: :person, dependent: :destroy

  scope :with_name, -> { joins(:authority).select('people.*, authorities.name') }

  has_paper_trail
  def died_years_ago
    dy = death_year.to_i
    return Date.today.year - dy
  rescue StandardError
    return 0
  end

  def birth_year
    return '?' if birthdate.nil?

    bpos = birthdate.strip_hebrew.index('-') # YYYYMMDD or YYYY is assumed
    return birthdate[0..bpos - 1].strip unless bpos.nil?
    return ::Regexp.last_match(0) if birthdate =~ /\d\d\d+/

    return birthdate
  end

  def gender_letter
    return gender == 'female' ? 'ה' : 'ו'
  end

  def blog_count
    return 0 # TODO: implement
  end

  def death_year
    return '?' if deathdate.nil?

    dpos = deathdate.strip_hebrew.index('-')
    return deathdate[0..dpos - 1].strip unless dpos.nil?
    return ::Regexp.last_match(0) if deathdate =~ /\d\d\d+/

    return deathdate
  end

  def life_years
    return "#{birth_year}&rlm;-#{death_year}"
  end

  def period_string
    return '' if period.nil?

    return t(period)
  end
end
