class FeaturedContentFeature < ApplicationRecord
  belongs_to :featured_content

  validates :fromdate, :todate, presence: true
end
