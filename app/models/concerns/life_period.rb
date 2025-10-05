# frozen_string_literal: true

# Helper methods to work with Person's life dates
# It assumes model including it has two string attributes: `deathdate` and `birthdate`
module LifePeriod
  extend ActiveSupport::Concern

  def birth_year
    ExtractYear.call(birthdate)
  end

  def death_year
    ExtractYear.call(deathdate)
  end

  def life_years
    return "#{birth_year}&rlm;-#{death_year}"
  end

  def died_years_ago
    dy = death_year.to_i
    return 0 if dy.zero?
    return Time.zone.today.year - dy
  rescue StandardError
    return 0
  end
end
