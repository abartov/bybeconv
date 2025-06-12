class YearTotal < ApplicationRecord
  belongs_to :item, polymorphic: true
end
