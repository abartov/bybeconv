class Bookmark < ApplicationRecord
  belongs_to :manifestation
  belongs_to :user
end
