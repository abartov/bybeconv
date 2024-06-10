# frozen_string_literal: true

# Base class for all models in BY project
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_impression
    year_totals_addition = year_totals.sum(:total)
    impcount = impressions.count
    # add the compacted totals from previous years to the live total from this year's impressions
    self.impressions_count = year_totals_addition + impcount
    save
  end

  def update_sort_title!
    return unless sort_title.blank? || (title_changed? && !sort_title_changed?)

    self.sort_title = title.strip_nikkud.tr('[]()*"\'', '').tr('-־', ' ').strip
    self.sort_title = ::Regexp.last_match.post_match if sort_title =~ /^\d+\. /
  end
end
