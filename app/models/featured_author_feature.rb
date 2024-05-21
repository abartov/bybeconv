class FeaturedAuthorFeature < ApplicationRecord
  belongs_to :featured_author, inverse_of: :featurings
end
