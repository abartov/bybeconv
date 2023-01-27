class Tagging < ApplicationRecord

  belongs_to :tag, foreign_key: 'tag_id'
  belongs_to :manifestation, foreign_key: 'manifestation_id'
  belongs_to :suggester, foreign_key: 'suggested_by', class_name: 'User'
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  validates :suggester, presence: true
  validates :status, presence: true
  validates :tag, presence: true
  validates :manifestation, presence: true
  
  enum status: [:pending, :approved, :rejected]

  scope :pending, -> { where(status: Tagging.statuses[:pending]) }
  scope :approved, -> { where(status: Tagging.statuses[:approved]) }
  scope :rejected, -> { where(status: Tagging.statuses[:rejected]) }
  scope :by_suggester, ->(user) { where(suggested_by: user.id) }

  def approve!(approver)
    self.approved_by = approver.id
    self.status = 'approved'
    self.save
  end
 
  def reject!(approver)
    self.approved_by = approver.id
    self.status = 'rejected'
    self.save
  end
end
