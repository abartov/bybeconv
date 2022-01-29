class Bookmark < ApplicationRecord
  belongs_to :manifestation
  belongs_to :base_user, inverse_of: :bookmarks
end
