class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_impression
    year_totals_addition = self.year_totals.sum(:total)
    impcount = self.impressions.count
    self.impressions_count = year_totals_addition + impcount # add the compacted totals from previous years to the live total from this year's impressions
    self.save
  end
  def update_sort_title!
    if self.sort_title.blank? || (self.title_changed? && !self.sort_title_changed?)
      self.sort_title = self.title.strip_nikkud.tr('[]()*"\'', '').tr('-־',' ').strip
      self.sort_title = $' if self.sort_title =~ /^\d+\. /
    end
  end
end 
