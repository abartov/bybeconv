class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  belongs_to :manifestation

  enum status: [:pending, :approved]

  scope :all_pending, -> { pending }
  scope :all_approved, -> { approved }
end
