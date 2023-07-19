class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_impression
    year_totals_addition = self.year_totals.sum(:total)
    impcount = self.impressions.count
    self.impressions_count = year_totals_addition + impcount # add the compacted totals from previous years to the live total from this year's impressions
    self.save
  end
end 
