class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def update_impression
    self.impressions_count += self.year_totals.sum(:total) # add the compacted totals from previous years to the live total from this year's impressions
    self.save
  end
end
