class YearTotal < ApplicationRecord
  belongs_to :item, polymorphic: true
  validates :year, :event, :total, presence: true
end
