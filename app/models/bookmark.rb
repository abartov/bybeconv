class Bookmark < ApplicationRecord
  belongs_to :manifestation
  belongs_to :base_user, inverse_of: :bookmarks

  validates_uniqueness_of :manifestation_id, scope: :base_user
end
