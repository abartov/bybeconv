class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  belongs_to :manifestation

  enum status: [:pending, :approved]

  scope :pending, -> { where(status: Recommendation.statuses[:pending]) }
  scope :approved, -> { where(status: Recommendation.statuses[:approved]) }
end
