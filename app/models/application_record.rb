class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_impression
    year_totals_addition = self.year_totals.sum(:total)
    self.impressions_count += year_totals_addition unless (self.impressions_count.nil? || year_totals_addition.nil?) # add the compacted totals from previous years to the live total from this year's impressions
    self.save
  end
end
