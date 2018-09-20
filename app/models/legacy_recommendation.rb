class LegacyRecommendation < ApplicationRecord

  belongs_to :html_file # legacy system (will be migrated or eliminated at some point; for now will co-exist quietly)
  belongs_to :manifestation # new system
  belongs_to :recommender, class_name: 'User', foreign_key: :recommended_by

  scope :approved, -> { where status: 'approved' }

end
